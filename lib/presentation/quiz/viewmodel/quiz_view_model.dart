import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../../ai_gen/viewmodel/ai_gen_view_model.dart';
import 'quiz_state.dart';

/// 풀이 세션 인자(과목 + 모드 + 이어풀기 여부). 레코드 값 동등성으로 family 키.
typedef QuizArgs = ({String categoryId, QuizMode mode, bool resume});

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, QuizArgs>(QuizViewModel.new);

/// 풀이 ViewModel — 모드에 맞는 세트를 로드하고 선택·다음·제출 의도를 처리한다.
/// normal 모드는 이어풀기 세션을 복원(build)·저장(next)·삭제(finish)한다.
class QuizViewModel extends AutoDisposeFamilyAsyncNotifier<QuizState, QuizArgs> {
  @override
  Future<QuizState> build(QuizArgs arg) async {
    // ai 모드는 런타임 생성 세트를 핸드오프 홀더에서 주입(저장소 로드 아님).
    final questions = arg.mode == QuizMode.ai
        ? ref.read(generatedQuestionsProvider)
        : await ref.watch(getQuestionSetProvider)(arg.categoryId, arg.mode);

    var startIndex = 0;
    var answers = List<int?>.filled(questions.length, null);
    if (arg.mode == QuizMode.normal && arg.resume) {
      final info = await ref.watch(getResumeInfoProvider)(arg.categoryId);
      if (info != null && info.lastIndex < questions.length) {
        startIndex = info.lastIndex;
        // 이전 세션의 선택을 복원(길이 방어) → 되돌아가면 답·해설이 되살아난다.
        for (var i = 0; i < questions.length && i < info.answers.length; i++) {
          answers[i] = info.answers[i];
        }
      }
    }
    return QuizState.initial(questions, arg.mode)
        .copyWith(index: startIndex, answers: answers);
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

    if (s.revealed) return; // 이미 채점된 문항은 재응답 불가
    // ai(참고용) 문항은 오답노트·통계에 기록하지 않는다(합성 id 오염 방지).
    if (arg.mode != QuizMode.ai) {
      await ref.read(submitAnswerProvider)(s.current, choiceIndex);
    }
    state = AsyncData(s.copyWith(answers: answers));
    // 선택 즉시 세션에 반영 → 재진입 시 이 답·해설이 복원된다.
    _saveSessionIfNormal(s.index, answers);
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
      state = AsyncData(s.copyWith(index: nextIndex));
      // 아직 안 푼 새 문항으로 나아갈 때만 이어풀기 위치를 전진 저장.
      // 뒤로 갔다 되돌아오는 중이면 최전방 위치를 유지한다.
      if (s.answers[nextIndex] == null) _saveSessionIfNormal(nextIndex, s.answers);
    }
  }

  /// 이전 문항으로(첫 문항이 하한). 복원된 답·해설을 그대로 다시 본다.
  /// 이어풀기 위치는 최전방을 유지하므로 여기서 저장하지 않는다.
  void prev() {
    final s = state.value;
    if (s == null || s.finished || !s.canGoPrev) return;
    state = AsyncData(s.copyWith(index: s.index - 1));
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

  void _saveSessionIfNormal(int index, List<int?> answers) {
    if (arg.mode == QuizMode.normal) {
      ref.read(saveSessionPositionProvider)(arg.categoryId, index, answers);
    }
  }

  void _clearSessionIfNormal() {
    if (arg.mode == QuizMode.normal) {
      ref.read(clearSessionProvider)(arg.categoryId);
    }
  }
}
