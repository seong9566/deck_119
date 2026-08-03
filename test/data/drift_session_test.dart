import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:deck_119/data/datasources/local/drift_session_data_source.dart';
import 'package:deck_119/data/repositories/session_repository_impl.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/domain/entities/recent_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 이어풀기 세션 저장→복원(Drift 인메모리).
void main() {
  late AppDatabase db;
  late SessionRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionRepositoryImpl(DriftSessionDataSource(db));
  });
  tearDown(() async => db.close());

  Future<void> save(
    String categoryId,
    QuizMode mode,
    int lastIndex,
    List<int?> answers, {
    List<String> questionIds = const [],
  }) =>
      repo.save(categoryId, mode,
          lastIndex: lastIndex, answers: answers, questionIds: questionIds);

  test('세션 저장 후 위치·답이 복원된다', () async {
    expect(await repo.load('s1', QuizMode.normal), isNull);

    await save('s1', QuizMode.normal, 3, [0, 1, 2, null]);
    var snap = await repo.load('s1', QuizMode.normal);
    expect(snap?.lastIndex, 3);
    expect(snap?.answers, [0, 1, 2, null]); // -1 sentinel ↔ null 왕복

    // upsert: 같은 과목·모드는 덮어쓴다(중복 생성 금지).
    await save('s1', QuizMode.normal, 7, [0, 1, 2, 3, null]);
    snap = await repo.load('s1', QuizMode.normal);
    expect(snap?.lastIndex, 7);
    expect(snap?.answers, [0, 1, 2, 3, null]);
  });

  test('출제 목록이 순서 그대로 복원된다', () async {
    await save('s1', QuizMode.random, 1, [2, null],
        questionIds: ['q9', 'q3', 'q7']);
    final snap = await repo.load('s1', QuizMode.random);
    expect(snap?.questionIds, ['q9', 'q3', 'q7']);
  });

  test('finish 시 세션 삭제', () async {
    await save('s1', QuizMode.normal, 5, [0]);
    await repo.clear('s1', QuizMode.normal);
    expect(await repo.load('s1', QuizMode.normal), isNull);
  });

  test('과목별로 세션이 분리된다', () async {
    await save('s1', QuizMode.normal, 2, [1, null]);
    await save('s2', QuizMode.normal, 9, [2, null]);
    expect((await repo.load('s1', QuizMode.normal))?.lastIndex, 2);
    expect((await repo.load('s2', QuizMode.normal))?.lastIndex, 9);
  });

  test('같은 과목이라도 모드별로 세션이 분리된다', () async {
    await save('s1', QuizMode.normal, 2, [1, null]);
    await save('s1', QuizMode.random, 5, [0, null], questionIds: ['q2', 'q1']);
    await save('s1', QuizMode.exam, 7, [3, null]);

    expect((await repo.load('s1', QuizMode.normal))?.lastIndex, 2);
    expect((await repo.load('s1', QuizMode.random))?.lastIndex, 5);
    expect((await repo.load('s1', QuizMode.exam))?.lastIndex, 7);

    // 한 모드를 지워도 다른 모드는 남는다.
    await repo.clear('s1', QuizMode.random);
    expect(await repo.load('s1', QuizMode.random), isNull);
    expect((await repo.load('s1', QuizMode.normal))?.lastIndex, 2);
  });

  test('recentSessions: 갱신 최신순 + 모드·문항수 포함', () async {
    final ds = DriftSessionDataSource(db);
    await ds.save('s1', 'normal', 1, [0], ['a'], nowMs: 100);
    await ds.save('s2', 'random', 2, [0], ['a', 'b', 'c'], nowMs: 300); // 최신
    await ds.save('s3', 'review', 3, [0], [], nowMs: 200);

    final recent = await repo.recentSessions(limit: 2);
    expect(recent.map((r) => r.collectionId).toList(), ['s2', 's3']);
    expect(recent.first.mode, QuizMode.random);
    expect(recent.first.total, 3);
    expect(recent.last.mode, QuizMode.review);
    expect(recent.last.total, 0, reason: '출제 목록이 없으면 미상(0)');
  });

  test('recentSessions: categoryId로 그 카테고리만 거른다', () async {
    final ds = DriftSessionDataSource(db);
    await ds.save('s1', 'normal', 1, [0], [], nowMs: 100);
    await ds.save('s2', 'normal', 2, [0], [], nowMs: 300);
    await ds.save('s1', 'exam', 4, [0], [], nowMs: 200);

    final recent = await repo.recentSessions(limit: 5, categoryId: 's1');
    expect(recent.map((r) => r.mode).toList(), [QuizMode.exam, QuizMode.normal]);
  });

  // drift .watch()의 초기 emit이 쓰기와 합쳐질 수 있어 emitsThrough로 단정.
  test('watchRecentSessions: 저장하면 최신 세션을 방출한다', () async {
    final done = expectLater(
      repo.watchRecentSessions(limit: 5),
      emitsThrough(
        predicate<List<RecentSession>>(
          (sessions) =>
              sessions.length == 1 &&
              sessions.first.collectionId == 'fire-law' &&
              sessions.first.mode == QuizMode.normal &&
              sessions.first.lastIndex == 3,
        ),
      ),
    );

    await save('fire-law', QuizMode.normal, 3, [0, 1, 2]);
    await done;
  });
}
