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

  test('세션 저장 후 위치·답이 복원된다', () async {
    final repo = SessionRepositoryImpl(IsarSessionDataSource(isar));
    expect(await repo.load('s1'), isNull);

    await repo.save('s1', 3, [0, 1, 2, null]);
    var snap = await repo.load('s1');
    expect(snap?.lastIndex, 3);
    expect(snap?.answers, [0, 1, 2, null]); // -1 sentinel ↔ null 왕복

    // upsert: 같은 과목은 덮어쓴다(중복 생성 금지).
    await repo.save('s1', 7, [0, 1, 2, 3, null]);
    snap = await repo.load('s1');
    expect(snap?.lastIndex, 7);
    expect(snap?.answers, [0, 1, 2, 3, null]);
    expect(await isar.sessionStates.count(), 1);
  });

  test('finish 시 세션 삭제', () async {
    final repo = SessionRepositoryImpl(IsarSessionDataSource(isar));
    await repo.save('s1', 5, [0]);
    await repo.clear('s1');
    expect(await repo.load('s1'), isNull);
  });

  test('과목별로 세션이 분리된다', () async {
    final repo = SessionRepositoryImpl(IsarSessionDataSource(isar));
    await repo.save('s1', 2, [1, null]);
    await repo.save('s2', 9, [2, null]);
    expect((await repo.load('s1'))?.lastIndex, 2);
    expect((await repo.load('s2'))?.lastIndex, 9);
  });

  test('recentSessions: 갱신 최신순으로 반환한다', () async {
    final ds = IsarSessionDataSource(isar);
    await ds.save('s1', 1, [0], nowMs: 100);
    await ds.save('s2', 2, [0], nowMs: 300); // 가장 최신
    await ds.save('s3', 3, [0], nowMs: 200);

    final repo = SessionRepositoryImpl(ds);
    final recent = await repo.recentSessions(limit: 2);
    expect(recent.map((r) => r.collectionId).toList(), ['s2', 's3']);
    expect(recent.first.lastIndex, 2);
  });
}
