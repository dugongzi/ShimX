import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shim/core/services/anthropic_messages_stream_to_responses_transformer.dart';
import 'package:shim/core/services/chat_stream_to_responses_transformer.dart';
import 'package:shim/core/services/llm_protocol_converter.dart';
import 'package:shim/core/services/llm_protocol_proxy_spec.dart';

final localProxyRunningPortProvider = Provider<ValueNotifier<int?>>((ref) {
  final notifier = ValueNotifier<int?>(null);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final localProxyServiceProvider = Provider<LocalProxyService>((ref) {
  final service = LocalProxyService();
  final runningPort = ref.read(localProxyRunningPortProvider);
  ref.onDispose(() {
    unawaited(service.stop());
    runningPort.value = null;
  });
  return service;
});

/// Current forwarding target: real provider base URL, key, model override, and protocol.
/// Protocol JSON fields are deliberately isolated in llm_protocol_converter.dart.
class ProxyTarget {
  const ProxyTarget({
    required this.baseUrl,
    required this.apiKey,
    this.model,
    this.upstreamProtocol = 'responses',
    this.reasoningEffort,
  });

  final String baseUrl;
  final String apiKey;
  final String? model;
  final String upstreamProtocol;
  final String? reasoningEffort;
}

/// Reverse proxy for Codex local requests.
///
/// This class only owns HTTP proxy flow. Request protocol mapping belongs to
/// llm_protocol_converter.dart; upstream route/header decisions belong to
/// llm_protocol_proxy_spec.dart.
class LocalProxyService {
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  int? _port;

  ProxyTarget? _target;

  bool get isRunning => _server != null;
  int? get port => _port;
  ProxyTarget? get target => _target;

  void setTarget(ProxyTarget target) {
    _target = target;
  }

  Future<void> start({required int port, ProxyTarget? target}) async {
    if (target != null) _target = target;
    if (_server != null && _port == port) return;
    await stop();

    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      port,
      shared: true,
    );
    _server = server;
    _port = server.port;
    // ignore: avoid_print
    print('[Proxy] listening 127.0.0.1:$port');
    _subscription = server.listen(
      _handleRequest,
      onError: (Object error, StackTrace stackTrace) {
        // ignore: avoid_print
        print('[Proxy] server error before handler: $error');
      },
    );
  }

  Future<void> stop() async {
    final subscription = _subscription;
    final server = _server;
    _subscription = null;
    _server = null;
    _port = null;
    await subscription?.cancel();
    await server?.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final target = _target;
    // ignore: avoid_print
    print('[Proxy] request ${request.method} ${request.uri} target=${target?.baseUrl}');
    if (target == null) {
      await _closeWithStatus(request.response, HttpStatus.serviceUnavailable);
      return;
    }

    late final LlmProtocolSpec spec;
    try {
      spec = resolveLlmProtocolSpec(
        baseUrl: target.baseUrl,
        requestUri: request.uri,
        apiKey: target.apiKey,
        upstreamProtocol: target.upstreamProtocol,
      );
    } catch (error) {
      // ignore: avoid_print
      print('[Proxy] invalid upstream target: $error');
      await _closeWithStatus(request.response, HttpStatus.badGateway);
      return;
    }

    // ignore: avoid_print
    print('[Proxy] forwarding to ${spec.uri} model=${target.model ?? "(passthrough)"}');

    final client = HttpClient();
    client.findProxy = (_) => 'DIRECT';
    var responseStarted = false;
    try {
      final upstreamRequest = await client.openUrl(request.method, spec.uri);
      _copyRequestHeaders(request, upstreamRequest, spec.uri.host);
      _applyProtocolHeaders(upstreamRequest, spec.headers);

      final bodyBytes = await _collectBody(request);
      final outBytes = convertLlmProtocolBody(
        bodyBytes,
        from: LlmProtocol.responses,
        to: spec.protocol,
        options: LlmRequestConvertOptions(
          overrideModel: target.model,
          reasoningEffort: target.reasoningEffort,
        ),
      );
      upstreamRequest.headers.contentLength = outBytes.length;
      upstreamRequest.add(outBytes);

      final upstreamResponse = await upstreamRequest.close();
      // ignore: avoid_print
      print('[Proxy] upstream ${upstreamResponse.statusCode} ${upstreamResponse.headers.contentType}');

      if (upstreamResponse.statusCode == HttpStatus.ok) {
        final transformed = await _tryTransformStream(
          spec.responseStreamKind,
          upstreamResponse,
          request.response,
        );
        if (transformed) {
          responseStarted = true;
          return;
        }
      }

      request.response.statusCode = upstreamResponse.statusCode;
      request.response.reasonPhrase = upstreamResponse.reasonPhrase;
      _copyResponseHeaders(upstreamResponse, request.response);
      responseStarted = true;
      await upstreamResponse.cast<List<int>>().pipe(request.response);
    } catch (error) {
      // ignore: avoid_print
      print('[Proxy] forwarding error: $error');
      if (!responseStarted) {
        await _closeWithStatus(request.response, HttpStatus.badGateway);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> _tryTransformStream(
    LlmResponseStreamKind streamKind,
    HttpClientResponse upstream,
    HttpResponse downstream,
  ) async {
    switch (streamKind) {
      case LlmResponseStreamKind.passthrough:
        return false;
      case LlmResponseStreamKind.chatToResponses:
        downstream.statusCode = HttpStatus.ok;
        await ChatStreamToResponsesTransformer().transform(upstream, downstream);
        return true;
      case LlmResponseStreamKind.messagesToResponses:
        downstream.statusCode = HttpStatus.ok;
        await AnthropicMessagesStreamToResponsesTransformer()
            .transform(upstream, downstream);
        return true;
    }
  }

  void _applyProtocolHeaders(
    HttpClientRequest request,
    Map<String, String> headers,
  ) {
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
  }

  Future<List<int>> _collectBody(HttpRequest request) {
    return request.fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
  }

  Future<void> _closeWithStatus(HttpResponse response, int statusCode) async {
    try {
      response.statusCode = statusCode;
      await response.close();
    } catch (_) {
      // The response may already be detached or closed by the socket layer.
    }
  }

  void _copyRequestHeaders(
    HttpRequest source,
    HttpClientRequest destination,
    String upstreamHost,
  ) {
    source.headers.forEach((name, values) {
      if (_isHopByHopHeader(name)) return;
      final lowerName = name.toLowerCase();
      if (lowerName == 'host') return;
      if (lowerName == 'authorization') return;
      for (final value in values) {
        destination.headers.add(name, value);
      }
    });
    destination.headers.set('host', upstreamHost);
  }

  void _copyResponseHeaders(
    HttpClientResponse source,
    HttpResponse destination,
  ) {
    source.headers.forEach((name, values) {
      if (_isHopByHopHeader(name)) return;
      for (final value in values) {
        destination.headers.add(name, value);
      }
    });
  }

  bool _isHopByHopHeader(String name) {
    switch (name.toLowerCase()) {
      case 'connection':
      case 'keep-alive':
      case 'proxy-authenticate':
      case 'proxy-authorization':
      case 'te':
      case 'trailer':
      case 'transfer-encoding':
      case 'upgrade':
        return true;
      default:
        return false;
    }
  }
}
