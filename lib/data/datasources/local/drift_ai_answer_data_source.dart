import 'dart:async';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// AI 생성 문항 풀이 기록의 Drift 저장소.
/// 통계·오답노트와 분리된 별도 테이블이라 합성 id가 기출 지표를 오염시키지 않는다.
class DriftAiAnswerDataSource {
  final AppDatabase _db;
  DriftAiAnswerDataSource(this._db);

  /// 응답 기록(같은 문항 재응답 시 덮어씀).
  Future<void> record(
    String questionId, {
    required String subjectId,
    required int selectedIndex,
    required bool isCorrect,
    required int nowMs,
  }) async {
    await _db.into(_db.aiAnswers).insertOnConflictUpdate(
          AiAnswersCompanion.insert(
            questionId: questionId,
            subjectId: subjectId,
            selectedIndex: selectedIndex,
            isCorrect: isCorrect,
            answeredAtMs: nowMs,
          ),
        );
  }

  /// 과목의 응답 기록(questionId → 선택 인덱스).
  Future<Map<String, int>> selections(String subjectId) async {
    final rows = await (_db.select(_db.aiAnswers)
          ..where((t) => t.subjectId.equals(subjectId)))
        .get();
    return {for (final r in rows) r.questionId: r.selectedIndex};
  }

  /// 과목의 기록 전체 삭제(처음부터 다시 풀기).
  Future<void> clearSubject(String subjectId) async {
    await (_db.delete(_db.aiAnswers)
          ..where((t) => t.subjectId.equals(subjectId)))
        .go();
  }

  /// 아직 풀지 않은 누적 문항 수(홈 카드 배지). 적립함 ⨯ 기록의 차집합이라
  /// 두 테이블을 조인해 한 번에 센다(두 스트림 결합 없이 갱신도 자동).
  Stream<int> watchUnsolvedCount(String subjectId) {
    return _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM generated_questions g '
          'LEFT JOIN ai_answers a ON a.question_id = g.id '
          'WHERE g.subject_id = ?1 AND a.question_id IS NULL',
          variables: [Variable<String>(subjectId)],
          readsFrom: {_db.generatedQuestions, _db.aiAnswers},
        )
        .watchSingle()
        .map((row) => row.read<int>('c'));
  }
}
