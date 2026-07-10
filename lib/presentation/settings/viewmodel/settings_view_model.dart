import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/app_theme_mode.dart';

/// 설정 ViewModel — 저장된 테마 모드를 로드하고 변경을 즉시 반영·영속화한다.
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppThemeMode>(
        SettingsController.new);

class SettingsController extends AsyncNotifier<AppThemeMode> {
  @override
  Future<AppThemeMode> build() => ref.watch(getThemeModeProvider)();

  /// 테마 변경: 화면 즉시 반영 후 저장.
  Future<void> setMode(AppThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(setThemeModeProvider)(mode);
  }
}
