import '../entities/question.dart';

/// AI 생성 문항 적립함(참고용). 생성분을 로컬에 누적 보관하고 재풀이에 제공한다.
abstract class GeneratedQuestionRepository {
  /// 생성분 누적 저장.
  Future<void> save(List<Question> questions);

  /// 누적 문항 최신순 전체.
  Future<List<Question>> getAll(String subjectId);

  /// 누적 개수 실시간 구독(홈 배지).
  Stream<int> watchCount(String subjectId);
}
