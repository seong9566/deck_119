import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/quiz_mode.dart';
import 'quiz_state.dart';

/// 풀이 세션 인자(과목 + 모드 + 이어풀기 여부). 레코드 값 동등성으로 family 키.
typedef QuizArgs = ({String subjectId, QuizMode mode, bool resume});

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, QuizArgs>(QuizViewModel.new);

/// 풀이 ViewModel — 모드에 맞는 세트를 로드하고 선택·다음·제출 의도를 처리한다.
/// normal 모드는 이어풀기 세션을 복원(build)·저장(next)·삭제(finish)한다.
class QuizViewModel extends AutoDisposeFamilyAsyncNotifier<QuizState, QuizArgs> {
  @override
  Future<QuizState> build(QuizArgs arg) async {
    final questions =
        await ref.watch(getQuestionSetProvider)(arg.subjectId, arg.mode);

    var startIndex = 0;
    if (arg.mode == QuizMode.normal && arg.resume) {
      final info = await ref.watch(getResumeInfoProvider)(arg.subjectId);
      if (info != null && info.lastIndex < questions.length) {
        startIndex = info.lastIndex;
      }
    }
    return QuizState.initial(questions, arg.mode).copyWith(index: startIndex);
  }

  /// 선택지 응답.
  /// - exam: 선택만 기록(재선택 허용), 채점 숨김.
  /// - normal 계열: 즉시 채점·오답 기록 후 해설 노출.
  Future<void> select(int choiceIndex) async {
    final s = state.value;
    if (s == null || s.isEmpty || s.finished) return;

    final answers = [...s.answers]..[s.index] = choiceIndex;

    if (s.isExam) {
      state = AsyncData(s.copyWith(answers: answers));
      return;
    }

    if (s.revealed) return;
    await ref.read(submitAnswerProvider)(s.current, choiceIndex);
    state = AsyncData(s.copyWith(answers: answers, revealed: true));
  }

  /// 다음 문항으로.
  /// - exam: 채점 없이 전진(마지막 문항은 submit으로만 종료).
  /// - normal 계열: 해설을 본 뒤에만 전진, 마지막이면 종료. normal은 세션 저장/삭제.
  void next() {
    final s = state.value;
    if (s == null || s.finished) return;

    if (s.isExam) {
      if (s.isLast) return;
      state = AsyncData(s.copyWith(index: s.index + 1));
      return;
    }

    if (!s.revealed) return;
    if (s.isLast) {
      state = AsyncData(s.copyWith(finished: true));
      _clearSessionIfNormal();
    } else {
      final nextIndex = s.index + 1;
      state = AsyncData(s.copyWith(index: nextIndex, revealed: false));
      _saveSessionIfNormal(nextIndex);
    }
  }

  /// 시험 제출 → 전 문항 일괄 채점·기록 후 결과로 종료(exam 전용).
  Future<void> submit() async {
    final s = state.value;
    if (s == null || !s.isExam || s.finished) return;

    final submitAnswer = ref.read(submitAnswerProvider);
    for (var i = 0; i < s.questions.length; i++) {
      await submitAnswer(s.questions[i], s.answers[i] ?? -1);
    }
    state = AsyncData(s.copyWith(finished: true));
  }

  void _saveSessionIfNormal(int index) {
    if (arg.mode == QuizMode.normal) {
      ref.read(saveSessionPositionProvider)(arg.subjectId, index);
    }
  }

  void _clearSessionIfNormal() {
    if (arg.mode == QuizMode.normal) {
      ref.read(clearSessionProvider)(arg.subjectId);
    }
  }
}
