import 'package:freezed_annotation/freezed_annotation.dart';

part 'codex_thread.freezed.dart';

@freezed
abstract class CodexThread with _$CodexThread {
  const CodexThread._();

  const factory CodexThread({
    required String id,
    required String title,
    required String preview,
    required String firstUserMessage,
    required String cwd,
    required bool archived,
    required int updatedAtMs,
    required int createdAtMs,
    required int tokensUsed,
    @Default('') String modelProvider,
  }) = _CodexThread;
}
