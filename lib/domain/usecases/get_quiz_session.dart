import '../entities/question.dart';
import '../entities/quiz_mode.dart';
import '../repositories/question_repository.dart';
import '../repositories/session_repository.dart';
import 'get_question_set.dart';

/// 풀이 시작 상태(세트 + 복원된 선택 + 시작 위치).
typedef QuizSessionData = ({
  List<Question> questions,
  List<int?> answers,
  int startIndex,
});

/// 풀이 세션 구성 — 이어풀기면 저장된 세트·선택·위치를 복원하고,
/// 아니면 모드에 맞는 새 세트를 만든다.
///
/// random·quick·review는 매번 세트가 달라지므로 저장된 출제 목록이 있으면
/// 그 순서를 그대로 되살린다(오답 재풀이는 시작 시점 목록 고정).
class GetQuizSession {
  final QuestionRepository _questions;
  final GetQuestionSet _getSet;
  final SessionRepository _session;

  GetQuizSession(this._questions, this._getSet, this._session);

  Future<QuizSessionData> call(
    String categoryId,
    QuizMode mode, {
    required bool resume,
  }) async {
    if (resume) {
      final snap = await _session.load(categoryId, mode);
      if (snap != null) {
        final restored = await _restore(categoryId, mode, snap);
        if (restored != null) return restored;
      }
    }
    return _fresh(categoryId, mode);
  }

  Future<QuizSessionData> _fresh(String categoryId, QuizMode mode) async {
    final questions = await _getSet(categoryId, mode);
    return (
      questions: questions,
      answers: List<int?>.filled(questions.length, null),
      startIndex: 0,
    );
  }

  /// 세션 스냅샷 → 세트 복원. 복원할 문항이 하나도 없으면 null(세션 폐기).
  Future<QuizSessionData?> _restore(
    String categoryId,
    QuizMode mode,
    SessionSnapshot snap,
  ) async {
    // v4 이전 세션은 출제 목록이 없다 → 저장소 순서를 그대로 쓴다.
    if (snap.questionIds.isEmpty) {
      final questions = await _getSet(categoryId, mode);
      if (questions.isEmpty) return null;
      final answers = List<int?>.filled(questions.length, null);
      for (var i = 0; i < questions.length && i < snap.answers.length; i++) {
        answers[i] = snap.answers[i];
      }
      return (
        questions: questions,
        answers: answers,
        startIndex: snap.lastIndex.clamp(0, questions.length - 1),
      );
    }

    final byId = {
      for (final q in await _questions.getQuestions(categoryId)) q.id: q,
    };
    final questions = <Question>[];
    final answers = <int?>[];
    var startIndex = 0;
    for (var i = 0; i < snap.questionIds.length; i++) {
      final q = byId[snap.questionIds[i]];
      if (q == null) continue; // 콘텐츠 갱신으로 사라진 문항은 건너뛴다
      // 사라진 문항만큼 앞당겨진 위치로 보정(마지막 생존 문항 기준).
      if (i <= snap.lastIndex) startIndex = questions.length;
      questions.add(q);
      answers.add(i < snap.answers.length ? snap.answers[i] : null);
    }
    if (questions.isEmpty) return null;
    return (
      questions: questions,
      answers: answers,
      startIndex: startIndex.clamp(0, questions.length - 1),
    );
  }
}
