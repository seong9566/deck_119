import '../entities/question.dart';
import '../repositories/progress_repository.dart';

/// 답 채점 + 진척·오답 기록.
class SubmitAnswer {
  final ProgressRepository _progress;

  SubmitAnswer(this._progress);

  Future<bool> call(Question question, int selectedIndex) async {
    final correct = question.isCorrect(selectedIndex);
    await _progress.recordAttempt(question.id, correct: correct);
    return correct;
  }
}
