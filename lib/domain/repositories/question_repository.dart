import '../entities/question.dart';
import '../entities/question_collection.dart';
import '../entities/subject.dart';

/// 콘텐츠(읽기 전용) 포트. 구현은 data 레이어(번들 JSON).
abstract interface class QuestionRepository {
  Future<List<Subject>> getSubjects();

  /// 선택 가능한 문제 세트 목록(원형 회차별·심화·전체).
  Future<List<QuestionCollection>> getCollections();

  /// 세트 id로 문제를 필터해 반환. id가 `subject::필터`면 필터 적용, 아니면 과목 전체.
  Future<List<Question>> getQuestions(String collectionId);
}
