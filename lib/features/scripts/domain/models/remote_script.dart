import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_script.freezed.dart';

@freezed
abstract class RemoteScript with _$RemoteScript {
  const RemoteScript._();

  const factory RemoteScript({
    required String id,
    required String name,
    required String description,
    required String version,
    required String author,
    required String fileName,
    required String downloadUrl,
    required String sha256,
  }) = _RemoteScript;
}
