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
  }) = _ApiProvider;
}
