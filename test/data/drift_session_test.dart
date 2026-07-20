import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:deck_119/data/datasources/local/drift_session_data_source.dart';
import 'package:deck_119/data/repositories/session_repository_impl.dart';
import 'package:deck_119/domain/entities/recent_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 이어풀기 세션 저장→복원(Drift 인메모리).
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('세션 저장 후 위치·답이 복원된다', () async {
    final repo = SessionRepositoryImpl(DriftSessionDataSource(db));
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
  });

  test('finish 시 세션 삭제', () async {
    final repo = SessionRepositoryImpl(DriftSessionDataSource(db));
    await repo.save('s1', 5, [0]);
    await repo.clear('s1');
    expect(await repo.load('s1'), isNull);
  });

  test('과목별로 세션이 분리된다', () async {
    final repo = SessionRepositoryImpl(DriftSessionDataSource(db));
    await repo.save('s1', 2, [1, null]);
    await repo.save('s2', 9, [2, null]);
    expect((await repo.load('s1'))?.lastIndex, 2);
    expect((await repo.load('s2'))?.lastIndex, 9);
  });

  test('recentSessions: 갱신 최신순으로 반환한다', () async {
    final ds = DriftSessionDataSource(db);
    await ds.save('s1', 1, [0], nowMs: 100);
    await ds.save('s2', 2, [0], nowMs: 300); // 가장 최신
    await ds.save('s3', 3, [0], nowMs: 200);

    final repo = SessionRepositoryImpl(ds);
    final recent = await repo.recentSessions(limit: 2);
    expect(recent.map((r) => r.collectionId).toList(), ['s2', 's3']);
    expect(recent.first.lastIndex, 2);
  });

  // drift .watch()의 초기 emit이 쓰기와 합쳐질 수 있어 emitsThrough로 단정.
  test('watchRecentSessions: 저장하면 최신 세션을 방출한다', () async {
    final repo = SessionRepositoryImpl(DriftSessionDataSource(db));
    final done = expectLater(
      repo.watchRecentSessions(limit: 5),
      emitsThrough(
        predicate<List<RecentSession>>(
          (sessions) =>
              sessions.length == 1 &&
              sessions.first.collectionId == 'fire-law' &&
              sessions.first.lastIndex == 3,
        ),
      ),
    );

    await repo.save('fire-law', 3, [0, 1, 2]);
    await done;
  });
}
