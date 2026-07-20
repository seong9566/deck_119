import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:deck_119/data/datasources/local/drift_progress_data_source.dart';
import 'package:deck_119/data/repositories/progress_repository_impl.dart';
import 'package:deck_119/domain/entities/progress_stats.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 진척·오답 저장(Drift 인메모리). 오답 저장→재조회·"정답 시 즉시 제거"·통계 집계.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('오답 저장 후 재조회된다', () async {
    final ds = DriftProgressDataSource(db);
    await ds.record('q1', correct: false, nowMs: 100);
    await ds.record('q2', correct: false, nowMs: 200);

    expect(await ds.wrongIds(), {'q1', 'q2'});
    expect((await ds.stats()).attempts, 2);
  });

  test('정답 시 오답 세트에서 즉시 제거된다', () async {
    final ds = DriftProgressDataSource(db);
    await ds.record('q1', correct: false, nowMs: 100);
    expect(await ds.wrongIds(), {'q1'});

    await ds.record('q1', correct: true, nowMs: 300);
    expect(await ds.wrongIds(), isEmpty);
    // 시도 이력은 남는다.
    expect((await ds.stats()).attempts, 2);
  });

  test('같은 오답을 두 번 기록해도 중복되지 않는다(unique key)', () async {
    final ds = DriftProgressDataSource(db);
    await ds.record('q1', correct: false, nowMs: 100);
    await ds.record('q1', correct: false, nowMs: 200);

    expect(await ds.wrongIds(), {'q1'});
  });

  test('ProgressRepositoryImpl 경유로도 오답이 유지된다', () async {
    final repo = ProgressRepositoryImpl(DriftProgressDataSource(db));
    await repo.recordAttempt('q9', correct: false);
    expect(await repo.getWrongIds(), {'q9'});

    await repo.recordAttempt('q9', correct: true);
    expect(await repo.getWrongIds(), isEmpty);
  });

  test('stats: 정답률·서로다른 문항수를 집계한다', () async {
    final ds = DriftProgressDataSource(db);
    final today = DateTime.now().millisecondsSinceEpoch;
    await ds.record('q1', correct: true, nowMs: today);
    await ds.record('q2', correct: false, nowMs: today);
    await ds.record('q1', correct: true, nowMs: today); // 같은 문항 재시도

    final s = await ds.stats();
    expect(s.attempts, 3);
    expect(s.correct, 2);
    expect(s.distinct, 2); // q1, q2
    expect(s.streak, 1); // 오늘 학습 → 연속 1일
  });

  test('stats: 오늘+어제 학습이면 연속 2일', () async {
    final ds = DriftProgressDataSource(db);
    final now = DateTime.now();
    final today = now.millisecondsSinceEpoch;
    final yesterday =
        now.subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    await ds.record('q1', correct: true, nowMs: yesterday);
    await ds.record('q2', correct: true, nowMs: today);

    expect((await ds.stats()).streak, 2);
  });

  test('stats: 시도 없으면 모두 0', () async {
    final s = await DriftProgressDataSource(db).stats();
    expect(s.attempts, 0);
    expect(s.streak, 0);
  });

  // drift .watch()는 초기값 전달 전에 쓰기가 끝나면 중간값을 합칠 수 있어
  // 초기 시퀀스가 아니라 emitsThrough로 "쓰기 후 목표 상태 방출"만 단정한다.
  test('watchStats: 시도를 기록하면 갱신된 통계를 방출한다', () async {
    final repo = ProgressRepositoryImpl(DriftProgressDataSource(db));
    final done = expectLater(
      repo.watchStats(),
      emitsThrough(predicate<ProgressStats>((stats) => stats.attempts == 1)),
    );

    await repo.recordAttempt('q1', correct: false);
    await done;
  });

  test('watchWrongIds: 오답을 추가하면 오답 세트를 방출한다', () async {
    final repo = ProgressRepositoryImpl(DriftProgressDataSource(db));
    final done = expectLater(repo.watchWrongIds(), emitsThrough(contains('q1')));

    await repo.recordAttempt('q1', correct: false);
    await done;
  });

  test('watchWrongIds: 정답 처리하면 오답 세트에서 제거해 방출한다', () async {
    final repo = ProgressRepositoryImpl(DriftProgressDataSource(db));
    await repo.recordAttempt('q1', correct: false); // 구독 전 오답 시드
    final done = expectLater(repo.watchWrongIds(), emitsThrough(isEmpty));

    await repo.recordAttempt('q1', correct: true);
    await done;
  });

  test('recordBatch: 혼합 결과를 한 번에 기록한다', () async {
    final ds = DriftProgressDataSource(db);
    await ds.recordBatch(
      [
        (questionId: 'q1', correct: true),
        (questionId: 'q2', correct: false),
        (questionId: 'q3', correct: false),
      ],
      nowMs: 100,
    );

    final s = await ds.stats();
    expect(s.attempts, 3);
    expect(s.correct, 1);
    expect(s.distinct, 3);
    expect(await ds.wrongIds(), {'q2', 'q3'}); // 오답만 세트에 남는다
  });
}
