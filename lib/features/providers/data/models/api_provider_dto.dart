import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/providers/domain/models/api_provider.dart';

part 'api_provider_dto.freezed.dart';
part 'api_provider_dto.g.dart';

@freezed
abstract class ApiProviderDto with _$ApiProviderDto {
  const ApiProviderDto._();

  const factory ApiProviderDto({
    @Default('') String id,
    @Default('') String name,
    @Default('') String baseUrl,
    @Default('') String apiKey,
    @Default([]) List<String> models,
    String? selectedModel,
    @Default('responses') String upstreamProtocol,
    @Default(5) int providerWeight,
    @Default(5) int modelWeight,
  }) = _ApiProviderDto;

  factory ApiProviderDto.fromJson(Map<String, Object?> json) =>
      _$ApiProviderDtoFromJson(json);

  factory ApiProviderDto.fromEntity(ApiProvider entity) {
    return ApiProviderDto(
      id: entity.id,
      name: entity.name,
      baseUrl: entity.baseUrl,
      apiKey: entity.apiKey,
      models: entity.models,
      selectedModel: entity.selectedModel,
      upstreamProtocol: entity.upstreamProtocol,
      providerWeight: entity.providerWeight,
      modelWeight: entity.modelWeight,
    );
  }

  ApiProvider toEntity() {
    return ApiProvider(
      id: id,
      name: name,
      baseUrl: baseUrl,
      apiKey: apiKey,
      models: models,
      selectedModel: selectedModel,
      upstreamProtocol: upstreamProtocol,
      providerWeight: providerWeight,
      modelWeight: modelWeight,
    );
  }
}
