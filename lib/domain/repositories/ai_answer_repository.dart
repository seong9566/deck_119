import '../entities/question.dart';

/// AI 생성 문항의 풀이 기록(포트). 통계·오답노트와 분리된 저장소를 쓴다.
abstract interface class AiAnswerRepository {
  /// 과목의 응답 기록(questionId → 선택 인덱스).
  Future<Map<String, int>> selections(String subjectId);

  /// 응답 기록(재응답 시 덮어씀).
  Future<void> record(Question question, int selectedIndex);

  /// 과목의 기록 전체 삭제(처음부터 다시 풀기).
  Future<void> clearSubject(String subjectId);

  /// 아직 풀지 않은 누적 문항 수(홈 카드 배지).
  Stream<int> watchUnsolvedCount(String subjectId);
}
