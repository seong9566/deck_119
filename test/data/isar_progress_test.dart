import 'dart:io';

import 'package:deck_119/data/datasources/local/collections/app_settings.dart';
import 'package:deck_119/data/datasources/local/collections/attempt_record.dart';
import 'package:deck_119/data/datasources/local/collections/session_state.dart';
import 'package:deck_119/data/datasources/local/collections/wrong_entry.dart';
import 'package:deck_119/data/datasources/local/isar_progress_data_source.dart';
import 'package:deck_119/data/repositories/progress_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../support/isar_test_core.dart';

/// T2 DoD: 오답 저장→재조회 · "정답 시 즉시 제거". 임시 Isar 인스턴스로 검증.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory dir;

  setUpAll(() async {
    await initIsarTestCore();
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('isar_test');
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

  test('오답 저장 후 재조회된다', () async {
    final ds = IsarProgressDataSource(isar);
    await ds.record('q1', correct: false, nowMs: 100);
    await ds.record('q2', correct: false, nowMs: 200);

    expect(await ds.wrongIds(), {'q1', 'q2'});
    expect(await isar.attemptRecords.count(), 2);
  });

  test('정답 시 오답 세트에서 즉시 제거된다', () async {
    final ds = IsarProgressDataSource(isar);
    await ds.record('q1', correct: false, nowMs: 100);
    expect(await ds.wrongIds(), {'q1'});

    await ds.record('q1', correct: true, nowMs: 300);
    expect(await ds.wrongIds(), isEmpty);
    // 시도 이력은 남는다.
    expect(await isar.attemptRecords.count(), 2);
  });

  test('같은 오답을 두 번 기록해도 중복되지 않는다(unique index)', () async {
    final ds = IsarProgressDataSource(isar);
    await ds.record('q1', correct: false, nowMs: 100);
    await ds.record('q1', correct: false, nowMs: 200);

    expect(await ds.wrongIds(), {'q1'});
    expect(await isar.wrongEntrys.count(), 1);
  });

  test('ProgressRepositoryImpl 경유로도 오답이 유지된다', () async {
    final repo = ProgressRepositoryImpl(IsarProgressDataSource(isar));
    await repo.recordAttempt('q9', correct: false);
    expect(await repo.getWrongIds(), {'q9'});

    await repo.recordAttempt('q9', correct: true);
    expect(await repo.getWrongIds(), isEmpty);
  });
}
