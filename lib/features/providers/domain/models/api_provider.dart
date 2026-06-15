import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_provider.freezed.dart';

/// API provider entity: one switchable upstream target.
@freezed
abstract class ApiProvider with _$ApiProvider {
  const ApiProvider._();

  const factory ApiProvider({
    required String id,
    required String name,

    /// Example: https://api.muxueai.pro/v1
    required String baseUrl,
    required String apiKey,

    /// Optional model list.
    required List<String> models,

    /// Selected model override. Null means Codex keeps its own model.
    required String? selectedModel,

    /// Upstream protocol storage value: responses | chat | messages.
    required String upstreamProtocol,
  }) = _ApiProvider;
}
