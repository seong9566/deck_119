import '../entities/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

/// 테마 모드 변경·저장.
class SetThemeMode {
  final SettingsRepository _settings;
  SetThemeMode(this._settings);

  Future<void> call(AppThemeMode mode) => _settings.setThemeMode(mode);
}
