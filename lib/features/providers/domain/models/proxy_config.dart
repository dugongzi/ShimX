import 'package:freezed_annotation/freezed_annotation.dart';

part 'proxy_config.freezed.dart';

/// 本地反向代理配置：开关 + 监听端口。
@freezed
abstract class ProxyConfig with _$ProxyConfig {
  const ProxyConfig._();

  const factory ProxyConfig({
    @Default(false) bool enabled,
    @Default(8787) int port,
  }) = _ProxyConfig;

  /// Codex config.toml 里要写的本地代理地址。
  /// Codex 发到这里，代理再转发到选中供应商的真实 base_url。
  String get localProxyUrl => 'http://127.0.0.1:$port/v1';
}
