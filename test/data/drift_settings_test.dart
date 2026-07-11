import 'dart:io';

import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:deck_119/data/datasources/local/drift_settings_data_source.dart';
import 'package:deck_119/data/repositories/settings_repository_impl.dart';
import 'package:deck_119/domain/entities/app_theme_mode.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테마 토글→저장→재로드 반영(Drift). 파일 DB를 닫았다 다시 열어 영속 확인.
void main() {
  test('기본값은 system', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = SettingsRepositoryImpl(DriftSettingsDataSource(db));
    expect(await repo.getThemeMode(), AppThemeMode.system);
    await db.close();
  });

  test('단일 레코드로 덮어쓴다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = SettingsRepositoryImpl(DriftSettingsDataSource(db));
    await repo.setThemeMode(AppThemeMode.light);
    await repo.setThemeMode(AppThemeMode.dark);
    expect(await repo.getThemeMode(), AppThemeMode.dark);
    expect((await db.select(db.settings).get()).length, 1);
    await db.close();
  });

  test('테마 저장 후 인스턴스를 다시 열어도 유지된다', () async {
    final dir = await Directory.systemTemp.createTemp('drift_settings');
    final file = File('${dir.path}/settings.sqlite');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    final db1 = AppDatabase.forTesting(NativeDatabase(file));
    await SettingsRepositoryImpl(DriftSettingsDataSource(db1))
        .setThemeMode(AppThemeMode.dark);
    await db1.close();

    final db2 = AppDatabase.forTesting(NativeDatabase(file));
    final mode =
        await SettingsRepositoryImpl(DriftSettingsDataSource(db2)).getThemeMode();
    expect(mode, AppThemeMode.dark);
    await db2.close();
  });
}
