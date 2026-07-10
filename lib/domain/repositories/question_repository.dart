import '../entities/question.dart';
import '../entities/subject.dart';

/// 콘텐츠(읽기 전용) 포트. 구현은 data 레이어(번들 JSON).
abstract interface class QuestionRepository {
  Future<List<Subject>> getSubjects();
  Future<List<Question>> getQuestions(String subjectId);
}
