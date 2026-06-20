import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shim/core/services/cdp_service.dart';

part 'bridge_service.g.dart';

const _bindingName = '__shimBridge';
const _bootstrapAssetPath = 'assets/inject/bridge_bootstrap.js';
const _devBootstrapPath =
    r'F:\Programming_projects\FlutterProject\shim\assets\inject\bridge_bootstrap.js';

typedef BridgeHandler = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> payload,
);

@Riverpod(keepAlive: true)
BridgeService bridgeService(Ref ref) {
  final service = BridgeService(ref.watch(cdpServiceProvider));
  service.register('/echo', (payload) async => {'status': 'ok', 'echo': payload});
  return service;
}

/// 在 CDP 之上建立 JS ↔ dart 双向通讯：
/// page 里暴露 window.shim(path, payload)，调用经 binding 路由到 dart handler。
class BridgeService {
  BridgeService(this._cdp);

  final CdpService _cdp;
  final Map<String, BridgeHandler> _routes = {};

  void register(String path, BridgeHandler handler) {
    _routes[path] = handler;
  }

  /// 在已建立的 CDP 连接上安装桥：binding + bootstrap + 业务脚本。
  Future<void> install({List<String> documentScripts = const []}) async {
    _cdp.onEvent = _onCdpEvent;
    await _cdp.sendCommand('Runtime.enable');
    await _cdp.sendCommand('Runtime.removeBinding', {'name': _bindingName});
    await _cdp.sendCommand('Runtime.addBinding', {'name': _bindingName});

    final bootstrap = await _loadBootstrap();
    await _cdp.injectScript(bootstrap);
    for (final script in documentScripts) {
      await _cdp.injectScript(script);
    }
  }

  void _onCdpEvent(Map<String, dynamic> event) {
    if (event['method'] != 'Runtime.bindingCalled') return;
    final params = (event['params'] as Map?)?.cast<String, dynamic>();
    if (params == null || params['name'] != _bindingName) return;
    _dispatch(params['payload'] as String?);
  }

  Future<void> _dispatch(String? payloadText) async {
    if (payloadText == null) return;
    final request = jsonDecode(payloadText) as Map<String, dynamic>;
    final id = request['id'] as String?;
    final path = request['path'] as String?;
    final payload =
        (request['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
    if (id == null || path == null) return;

    try {
      final handler = _routes[path];
      if (handler == null) {
        await _replyJs(id, _failure('unknown bridge path: $path'));
        return;
      }
      final data = await handler(payload);
      await _replyJs(id, _success(data));
    } catch (error) {
      await _replyJs(id, _failure(error.toString()));
    }
  }

  Map<String, dynamic> _success(Map<String, dynamic> data) {
    return {'code': 0, 'data': data, 'message': ''};
  }

  Map<String, dynamic> _failure(String message) {
    return {'code': -1, 'data': null, 'message': message};
  }

  Future<void> _replyJs(String id, Map<String, dynamic> envelope) {
    return _cdp.evaluate(
      'window.__shimResolve(${jsonEncode(id)}, ${jsonEncode(envelope)})',
    );
  }

  /// 从 dart 主动向 JS 推一条事件。JS 侧用 window.__shimEvent(path, listener) 订阅。
  /// 失败静默(可能注入未就绪),不抛出。
  void dispatchEvent(String path, Map<String, dynamic> payload) {
    () async {
      try {
        await _cdp.evaluate(
          'window.__shimDispatch && window.__shimDispatch(${jsonEncode(path)}, ${jsonEncode(payload)})',
        );
      } catch (_) {}
    }();
  }

  Future<String> _loadBootstrap() async {
    if (kDebugMode) {
      final source = File(_devBootstrapPath);
      if (await source.exists()) return source.readAsString();
    }
    return rootBundle.loadString(_bootstrapAssetPath);
  }
}
