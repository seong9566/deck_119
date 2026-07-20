import 'dart:async';

import 'app_database.dart';

/// 진척·오답의 Drift 저장소. (구 IsarProgressDataSource 대체 — 시그니처 동일)
class DriftProgressDataSource {
  final AppDatabase _db;
  DriftProgressDataSource(this._db);

  /// 채점 결과 기록: 오답이면 WrongEntry upsert(정답이면 즉시 제거),
  /// 시도 이력은 AttemptRecord로 append.
  Future<void> record(String questionId,
      {required bool correct, required int nowMs}) async {
    await _db.transaction(() async {
      if (correct) {
        await (_db.delete(_db.wrongEntries)
              ..where((t) => t.questionId.equals(questionId)))
            .go();
      } else {
        await _db.into(_db.wrongEntries).insertOnConflictUpdate(
              WrongEntriesCompanion.insert(
                  questionId: questionId, addedAtMs: nowMs),
            );
      }
      await _db.into(_db.attemptRecords).insert(
            AttemptRecordsCompanion.insert(
                questionId: questionId, isCorrect: correct, timestampMs: nowMs),
          );
    });
  }

  /// 여러 시도를 단일 트랜잭션으로 기록(시험 제출용). 트랜잭션 커밋 후
  /// 드리프트가 테이블 변경 알림을 1회로 합쳐 watch 재집계 폭주를 막는다.
  Future<void> recordBatch(
    List<({String questionId, bool correct})> items, {
    required int nowMs,
  }) async {
    await _db.transaction(() async {
      for (final it in items) {
        if (it.correct) {
          await (_db.delete(_db.wrongEntries)
                ..where((t) => t.questionId.equals(it.questionId)))
              .go();
        } else {
          await _db.into(_db.wrongEntries).insertOnConflictUpdate(
                WrongEntriesCompanion.insert(
                    questionId: it.questionId, addedAtMs: nowMs),
              );
        }
        await _db.into(_db.attemptRecords).insert(
              AttemptRecordsCompanion.insert(
                  questionId: it.questionId,
                  isCorrect: it.correct,
                  timestampMs: nowMs),
            );
      }
    });
  }

  /// 오답 세트(문제 id).
  Future<Set<String>> wrongIds() async {
    final rows = await _db.select(_db.wrongEntries).get();
    return rows.map((e) => e.questionId).toSet();
  }

  /// 오답 세트(문제 id) 스트림.
  Stream<Set<String>> watchWrongIds() {
    return _db.select(_db.wrongEntries).watch().map(
          (rows) => rows.map((e) => e.questionId).toSet(),
        );
  }

  /// 오답 세트에서 제거.
  Future<void> clear(String questionId) async {
    await (_db.delete(_db.wrongEntries)
          ..where((t) => t.questionId.equals(questionId)))
        .go();
  }

  /// 시도 로그 집계: (총시도, 정답, 서로다른 문항수, 연속학습일수).
  Future<({int attempts, int correct, int distinct, int streak})>
      stats() async {
    final all = await _db.select(_db.attemptRecords).get();
    return _aggregate(all);
  }

  /// 시도 로그 집계 스트림.
  Stream<({int attempts, int correct, int distinct, int streak})>
      watchStats() {
    return _db.select(_db.attemptRecords).watch().map(_aggregate);
  }

  static ({int attempts, int correct, int distinct, int streak}) _aggregate(
      List<AttemptRecord> all) {
    var correct = 0;
    final ids = <String>{};
    final days = <int>{}; // 로컬 자정 기준 epoch day
    for (final a in all) {
      if (a.isCorrect) correct++;
      ids.add(a.questionId);
      final d = DateTime.fromMillisecondsSinceEpoch(a.timestampMs);
      days.add(DateTime(d.year, d.month, d.day).millisecondsSinceEpoch);
    }
    return (
      attempts: all.length,
      correct: correct,
      distinct: ids.length,
      streak: _streak(days),
    );
  }

  /// 연속 학습일수: 오늘(없으면 어제)부터 하루씩 거슬러 끊기지 않은 날 수.
  static int _streak(Set<int> days) {
    if (days.isEmpty) return 0;
    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor.millisecondsSinceEpoch)) {
      cursor = cursor.subtract(const Duration(days: 1)); // 오늘 미학습 → 어제부터
      if (!days.contains(cursor.millisecondsSinceEpoch)) return 0;
    }
    var count = 0;
    while (days.contains(cursor.millisecondsSinceEpoch)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}
