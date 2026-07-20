import '../entities/question.dart';
import '../entities/question_category.dart';
import '../entities/subject.dart';

/// 콘텐츠(읽기 전용) 포트. 구현은 data 레이어(번들 JSON).
abstract interface class QuestionRepository {
  Future<List<Subject>> getSubjects();

  /// 선택 가능한 카테고리 목록(법령별·교차법령·심화 OX·계산 + 전체).
  Future<List<QuestionCategory>> getCategories();

  /// 카테고리 id로 문제를 필터해 반환. 전체(과목 id)면 전 문항, 아니면 그 카테고리 문항.
  Future<List<Question>> getQuestions(String collectionId);
}
