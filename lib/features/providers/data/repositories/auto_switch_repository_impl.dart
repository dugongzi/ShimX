import 'package:shim/features/providers/data/datasources/auto_switch_datasource.dart';
import 'package:shim/features/providers/data/models/auto_switch_settings_dto.dart';
import 'package:shim/features/providers/domain/models/auto_switch_settings.dart';
import 'package:shim/features/providers/domain/repositories/auto_switch_repository.dart';

class AutoSwitchRepositoryImpl implements AutoSwitchRepository {
  final AutoSwitchDatasource dataSource;

  AutoSwitchRepositoryImpl({required this.dataSource});

  @override
  Future<AutoSwitchSettings> read() async {
    final dto = await dataSource.read();
    return (dto ?? const AutoSwitchSettingsDto()).toEntity();
  }

  @override
  Future<void> save({required AutoSwitchSettings settings}) {
    return dataSource.write(
      dto: AutoSwitchSettingsDto.fromEntity(settings),
    );
  }
}
