import 'dart:io';

import 'package:deck_119/data/datasources/local/collections/app_settings.dart';
import 'package:deck_119/data/datasources/local/collections/attempt_record.dart';
import 'package:deck_119/data/datasources/local/collections/session_state.dart';
import 'package:deck_119/data/datasources/local/collections/wrong_entry.dart';
import 'package:deck_119/data/datasources/local/isar_session_data_source.dart';
import 'package:deck_119/data/repositories/session_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../support/isar_test_core.dart';

/// T4 DoD: 세션 저장→복원. 임시 Isar 인스턴스로 검증.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory dir;

  setUpAll(() async => initIsarTestCore());

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('isar_session');
    isar = await Isar.open(
      [
        WrongEntrySchema,
        AttemptRecordSchema,
        SessionStateSchema,
        AppSettingsSchema,
      ],
      directory: dir.path,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('세션 저장 후 복원된다', () async {
    final repo = SessionRepositoryImpl(IsarSessionDataSource(isar));
    expect(await repo.getLastIndex('s1'), isNull);

    await repo.save('s1', 3);
    expect(await repo.getLastIndex('s1'), 3);

    // upsert: 같은 과목은 덮어쓴다(중복 생성 금지).
    await repo.save('s1', 7);
    expect(await repo.getLastIndex('s1'), 7);
    expect(await isar.sessionStates.count(), 1);
  });

  test('finish 시 세션 삭제', () async {
    final repo = SessionRepositoryImpl(IsarSessionDataSource(isar));
    await repo.save('s1', 5);
    await repo.clear('s1');
    expect(await repo.getLastIndex('s1'), isNull);
  });

  test('과목별로 세션이 분리된다', () async {
    final repo = SessionRepositoryImpl(IsarSessionDataSource(isar));
    await repo.save('s1', 2);
    await repo.save('s2', 9);
    expect(await repo.getLastIndex('s1'), 2);
    expect(await repo.getLastIndex('s2'), 9);
  });
}
