import 'dart:io';

import 'package:deck_119/data/datasources/local/collections/app_settings.dart';
import 'package:deck_119/data/datasources/local/collections/attempt_record.dart';
import 'package:deck_119/data/datasources/local/collections/session_state.dart';
import 'package:deck_119/data/datasources/local/collections/wrong_entry.dart';
import 'package:deck_119/data/datasources/local/isar_settings_data_source.dart';
import 'package:deck_119/data/repositories/settings_repository_impl.dart';
import 'package:deck_119/domain/entities/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../support/isar_test_core.dart';

/// T5 DoD: 토글→저장→재로드 반영. 인스턴스를 닫았다 다시 열어 영속 확인.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUpAll(() async => initIsarTestCore());

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('isar_settings');
  });

  tearDown(() async {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  final schemas = [
    WrongEntrySchema,
    AttemptRecordSchema,
    SessionStateSchema,
    AppSettingsSchema,
  ];

  test('기본값은 system', () async {
    final isar = await Isar.open(schemas, directory: dir.path, name: 'a');
    final repo = SettingsRepositoryImpl(IsarSettingsDataSource(isar));
    expect(await repo.getThemeMode(), AppThemeMode.system);
    await isar.close();
  });

  test('테마 저장 후 인스턴스를 다시 열어도 유지된다', () async {
    final isar1 = await Isar.open(schemas, directory: dir.path, name: 'b');
    await SettingsRepositoryImpl(IsarSettingsDataSource(isar1))
        .setThemeMode(AppThemeMode.dark);
    await isar1.close();

    final isar2 = await Isar.open(schemas, directory: dir.path, name: 'b');
    final mode =
        await SettingsRepositoryImpl(IsarSettingsDataSource(isar2)).getThemeMode();
    expect(mode, AppThemeMode.dark);
    await isar2.close();
  });

  test('단일 레코드로 덮어쓴다', () async {
    final isar = await Isar.open(schemas, directory: dir.path, name: 'c');
    final repo = SettingsRepositoryImpl(IsarSettingsDataSource(isar));
    await repo.setThemeMode(AppThemeMode.light);
    await repo.setThemeMode(AppThemeMode.dark);
    expect(await isar.appSettings.count(), 1);
    expect(await repo.getThemeMode(), AppThemeMode.dark);
    await isar.close();
  });
}
