import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/scripts/domain/models/script_metadata.dart';

part 'inject_script.freezed.dart';

@freezed
abstract class InjectScript with _$InjectScript {
  const InjectScript._();

  const factory InjectScript({
    required String id,
    required String filePath,
    required ScriptMetadata metadata,
    required String code,
  }) = _InjectScript;
}
