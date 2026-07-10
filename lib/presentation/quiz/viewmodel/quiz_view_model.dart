import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/quiz_mode.dart';
import 'quiz_state.dart';

/// 풀이 세션 인자(과목 + 모드). 레코드 값 동등성으로 family 키가 된다.
typedef QuizArgs = ({String subjectId, QuizMode mode});

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, QuizArgs>(QuizViewModel.new);

/// 풀이 ViewModel — 모드에 맞는 세트를 로드하고 선택·다음·제출 의도를 처리한다.
/// UseCase만 호출하고 Repository 구현·저장소를 모른다(MVVM + 클린 아키텍처).
class QuizViewModel extends AutoDisposeFamilyAsyncNotifier<QuizState, QuizArgs> {
  @override
  Future<QuizState> build(QuizArgs arg) async {
    final questions =
        await ref.watch(getQuestionSetProvider)(arg.subjectId, arg.mode);
    return QuizState.initial(questions, arg.mode);
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
  /// - normal 계열: 해설을 본 뒤에만 전진, 마지막이면 종료.
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
    } else {
      state = AsyncData(s.copyWith(index: s.index + 1, revealed: false));
    }
  }

  /// 시험 제출 → 전 문항 일괄 채점·기록 후 결과로 종료(exam 전용).
  Future<void> submit() async {
    final s = state.value;
    if (s == null || !s.isExam || s.finished) return;

    final submitAnswer = ref.read(submitAnswerProvider);
    for (var i = 0; i < s.questions.length; i++) {
      // 미응답(-1)은 오답으로 채점·기록된다.
      await submitAnswer(s.questions[i], s.answers[i] ?? -1);
    }
    state = AsyncData(s.copyWith(finished: true));
  }
}
