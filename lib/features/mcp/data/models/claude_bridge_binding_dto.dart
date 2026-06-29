import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/core/services/local_proxy_service.dart';

part 'claude_bridge_binding_dto.freezed.dart';
part 'claude_bridge_binding_dto.g.dart';

/// codex thread id → 它绑定的 Claude 会话快照。
///
/// 持久化形式:`SharedPreferences['claude_bridge_bindings_v1']`
/// 值为 JSON map(codexThreadId → {sessionId, jsonlPath, title?})。
@freezed
abstract class ClaudeBridgeBindingDto with _$ClaudeBridgeBindingDto {
  const ClaudeBridgeBindingDto._();

  const factory ClaudeBridgeBindingDto({
    required String codexThreadId,
    @Default('') String sessionId,
    @Default('') String jsonlPath,
    String? title,
  }) = _ClaudeBridgeBindingDto;

  factory ClaudeBridgeBindingDto.fromJson(Map<String, dynamic> json) =>
      _$ClaudeBridgeBindingDtoFromJson(json);

  /// 持久化文件里没有 codexThreadId 字段(它是 map key),这里手动补。
  factory ClaudeBridgeBindingDto.fromStorageEntry({
    required String codexThreadId,
    required Map<String, Object?> json,
  }) {
    return ClaudeBridgeBindingDto(
      codexThreadId: codexThreadId,
      sessionId: (json['sessionId'] as String?) ?? '',
      jsonlPath: (json['jsonlPath'] as String?) ?? '',
      title: json['title'] as String?,
    );
  }

  factory ClaudeBridgeBindingDto.fromBinding({
    required String codexThreadId,
    required ClaudeBridgeBinding binding,
  }) {
    return ClaudeBridgeBindingDto(
      codexThreadId: codexThreadId,
      sessionId: binding.sessionId,
      jsonlPath: binding.jsonlPath,
      title: binding.title,
    );
  }

  ClaudeBridgeBinding toBinding() {
    return ClaudeBridgeBinding(
      sessionId: sessionId,
      jsonlPath: jsonlPath,
      title: title,
    );
  }

  /// 持久化时去掉 codexThreadId(它在外层 map key);空 title 不写。
  Map<String, Object?> toStorageJson() {
    return {
      'sessionId': sessionId,
      'jsonlPath': jsonlPath,
      if (title != null && title!.isNotEmpty) 'title': title,
    };
  }

  bool get isValid =>
      codexThreadId.isNotEmpty && sessionId.isNotEmpty && jsonlPath.isNotEmpty;
}
