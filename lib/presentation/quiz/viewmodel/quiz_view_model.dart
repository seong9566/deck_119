import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/quiz_mode.dart';
import 'quiz_state.dart';

/// 풀이 세션 인자(과목 + 모드). 레코드 값 동등성으로 family 키가 된다.
typedef QuizArgs = ({String subjectId, QuizMode mode});

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, QuizArgs>(QuizViewModel.new);

/// 풀이 ViewModel — 모드에 맞는 세트를 로드하고 선택·다음 의도를 처리한다.
/// UseCase만 호출하고 Repository 구현·저장소를 모른다(MVVM + 클린 아키텍처).
class QuizViewModel
    extends AutoDisposeFamilyAsyncNotifier<QuizState, QuizArgs> {
  @override
  Future<QuizState> build(QuizArgs arg) async {
    final questions =
        await ref.watch(getQuestionSetProvider)(arg.subjectId, arg.mode);
    return QuizState.initial(questions);
  }

  /// 선택지 응답 → 채점·오답 기록 후 해설 노출.
  Future<void> select(int choiceIndex) async {
    final s = state.value;
    if (s == null || s.isEmpty || s.revealed || s.finished) return;

    final correct = await ref.read(submitAnswerProvider)(s.current, choiceIndex);
    state = AsyncData(QuizState(
      questions: s.questions,
      index: s.index,
      selected: choiceIndex,
      revealed: true,
      correctCount: s.correctCount + (correct ? 1 : 0),
      finished: false,
    ));
  }

  /// 다음 문항으로. 마지막이면 종료.
  void next() {
    final s = state.value;
    if (s == null || !s.revealed) return;

    if (s.isLast) {
      state = AsyncData(QuizState(
        questions: s.questions,
        index: s.index,
        selected: s.selected,
        revealed: true,
        correctCount: s.correctCount,
        finished: true,
      ));
    } else {
      state = AsyncData(QuizState(
        questions: s.questions,
        index: s.index + 1,
        selected: null,
        revealed: false,
        correctCount: s.correctCount,
        finished: false,
      ));
    }
  }
}
