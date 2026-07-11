import '../entities/question.dart';
import '../entities/quiz_mode.dart';
import '../repositories/progress_repository.dart';
import '../repositories/question_repository.dart';

/// 모드에 맞는 문제 세트를 구성한다(로직 있는 UseCase).
class GetQuestionSet {
  final QuestionRepository _questions;
  final ProgressRepository _progress;

  GetQuestionSet(this._questions, this._progress);

  Future<List<Question>> call(String subjectId, QuizMode mode) async {
    final all = await _questions.getQuestions(subjectId);
    switch (mode) {
      case QuizMode.normal:
      case QuizMode.exam:
        return all;
      case QuizMode.random:
        return [...all]..shuffle();
      case QuizMode.quick:
        return ([...all]..shuffle()).take(10).toList();
      case QuizMode.review:
        final wrong = await _progress.getWrongIds();
        return all.where((q) => wrong.contains(q.id)).toList();
    }
  }
}
