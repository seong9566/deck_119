import 'package:isar/isar.dart';

import 'collections/attempt_record.dart';
import 'collections/wrong_entry.dart';

/// 진척·오답의 Isar 저장소(BUILD_PLAN §2). 인메모리 구현을 대체한다.
class IsarProgressDataSource {
  final Isar _isar;
  IsarProgressDataSource(this._isar);

  /// 채점 결과 기록: 오답이면 WrongEntry put(정답이면 즉시 제거),
  /// 시도 이력은 AttemptRecord로 append.
  Future<void> record(String questionId,
      {required bool correct, required int nowMs}) async {
    await _isar.writeTxn(() async {
      if (correct) {
        await _isar.wrongEntrys
            .deleteByQuestionId(questionId); // 즉시 제거 규칙
      } else {
        await _isar.wrongEntrys.putByQuestionId(
          WrongEntry()
            ..questionId = questionId
            ..addedAtMs = nowMs,
        );
      }
      await _isar.attemptRecords.put(
        AttemptRecord()
          ..questionId = questionId
          ..isCorrect = correct
          ..timestampMs = nowMs,
      );
    });
  }

  /// 오답 세트(문제 id).
  Future<Set<String>> wrongIds() async {
    final entries = await _isar.wrongEntrys.where().findAll();
    return entries.map((e) => e.questionId).toSet();
  }

  /// 오답 세트에서 제거.
  Future<void> clear(String questionId) async {
    await _isar.writeTxn(() async {
      await _isar.wrongEntrys.deleteByQuestionId(questionId);
    });
  }

  /// 시도 로그 집계: (총시도, 정답, 서로다른 문항수, 연속학습일수).
  Future<({int attempts, int correct, int distinct, int streak})>
      stats() async {
    final all = await _isar.attemptRecords.where().findAll();
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
