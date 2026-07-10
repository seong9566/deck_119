import 'package:isar/isar.dart';

import 'collections/app_settings.dart';

/// 앱 설정의 Isar 저장소(BUILD_PLAN §2). 단일 레코드(id=0).
class IsarSettingsDataSource {
  static const int _id = 0;
  final Isar _isar;
  IsarSettingsDataSource(this._isar);

  /// 저장된 테마 문자열(없으면 null).
  Future<String?> themeMode() async {
    final row = await _isar.appSettings.get(_id);
    return row?.themeMode;
  }

  Future<void> setThemeMode(String value) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(
        AppSettings()
          ..id = _id
          ..themeMode = value,
      );
    });
  }
}
