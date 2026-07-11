import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/drift_settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final DriftSettingsDataSource _local;
  SettingsRepositoryImpl(this._local);

  @override
  Future<AppThemeMode> getThemeMode() async {
    return AppThemeMode.fromStorage(await _local.themeMode());
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) =>
      _local.setThemeMode(mode.storageValue);
}
