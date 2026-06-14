import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shim/features/providers/domain/models/api_provider.dart';

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
  }) = _ApiProviderDto;

  factory ApiProviderDto.fromJson(Map<String, dynamic> json) =>
      _$ApiProviderDtoFromJson(json);

  factory ApiProviderDto.fromEntity(ApiProvider entity) {
    return ApiProviderDto(
      id: entity.id,
      name: entity.name,
      baseUrl: entity.baseUrl,
      apiKey: entity.apiKey,
    );
  }

  ApiProvider toEntity() {
    return ApiProvider(
      id: id,
      name: name,
      baseUrl: baseUrl,
      apiKey: apiKey,
    );
  }
}
