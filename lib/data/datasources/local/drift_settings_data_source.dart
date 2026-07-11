import 'package:drift/drift.dart';

import 'app_database.dart';

/// 앱 설정의 Drift 저장소. 단일 레코드(id=0).
/// (구 IsarSettingsDataSource 대체 — 시그니처 동일)
class DriftSettingsDataSource {
  static const int _id = 0;
  final AppDatabase _db;
  DriftSettingsDataSource(this._db);

  /// 저장된 테마 문자열(없으면 null).
  Future<String?> themeMode() async {
    final row = await (_db.select(_db.settings)..where((t) => t.id.equals(_id)))
        .getSingleOrNull();
    return row?.themeMode;
  }

  Future<void> setThemeMode(String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(id: const Value(_id), themeMode: value),
        );
  }
}
