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
}
