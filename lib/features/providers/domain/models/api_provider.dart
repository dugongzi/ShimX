import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_provider.freezed.dart';

/// API 供应商实体：一条可切换的中转目标。
@freezed
abstract class ApiProvider with _$ApiProvider {
  const ApiProvider._();

  const factory ApiProvider({
    required String id,
    required String name,

    /// 例：https://api.muxueai.pro/v1
    required String baseUrl,
    required String apiKey,

    /// 可选模型列表
    required List<String> models,

    /// 当前选中模型（null = 不覆盖，用 Codex 自己选的）
    required String? selectedModel,

    /// 上游协议：'responses'（默认）| 'chat'
    required String wireApi,
  }) = _ApiProvider;
}
