import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../../ai_gen/viewmodel/ai_gen_view_model.dart';
import 'quiz_state.dart';

/// 풀이 세션 인자(과목 + 모드 + 이어풀기 여부). 레코드 값 동등성으로 family 키.
typedef QuizArgs = ({String categoryId, QuizMode mode, bool resume});

final quizViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, QuizArgs>(QuizViewModel.new);

/// 풀이 ViewModel — 모드에 맞는 세트를 로드하고 선택·다음·제출 의도를 처리한다.
/// 모든 모드가 이어풀기 세션을 복원(build)·저장(select/next)·삭제(finish)한다.
/// ai 모드만 예외 — 문항이 계속 누적되므로 세션 대신 문항별 응답 기록이 원천이다.
class QuizViewModel extends AutoDisposeFamilyAsyncNotifier<QuizState, QuizArgs> {
  @override
  Future<QuizState> build(QuizArgs arg) async {
    // ai 모드는 홈에서 구성한 세트를 핸드오프 홀더에서 주입(저장소 로드 아님).
    if (arg.mode == QuizMode.ai) {
      final set = ref.read(aiQuizSetProvider);
      return QuizState(
        questions: set.questions,
        mode: arg.mode,
        answers: [...set.answers],
        index: set.firstUnsolvedIndex,
      );
    }

    final data = await ref.watch(getQuizSessionProvider)(
      arg.categoryId,
      arg.mode,
      resume: arg.resume,
    );
    return QuizState(
      questions: data.questions,
      mode: arg.mode,
      answers: data.answers,
      index: data.startIndex,
    );
  }

  /// 선택지 응답.
  /// - exam: 선택만 기록(재선택 허용), 채점 숨김.
  /// - normal 계열: 즉시 채점·기록 후 해설 노출.
  Future<void> select(int choiceIndex) async {
    final s = state.value;
    if (s == null || s.isEmpty || s.finished) return;

    final answers = [...s.answers]..[s.index] = choiceIndex;

    if (s.isExam) {
      state = AsyncData(s.copyWith(answers: answers));
      // 제출 전까지 임시저장 → 도중에 나가도 고른 답이 남는다.
      _saveSession(s.index, answers, s.questions);
      return;
    }

    if (s.revealed) return; // 이미 채점된 문항은 재응답 불가
    // ai(참고용) 문항은 통계·오답노트가 아니라 AI 전용 기록에 남긴다
    // (합성 id 오염 방지 — ADR-0002).
    if (arg.mode == QuizMode.ai) {
      await ref.read(recordAiAnswerProvider)(s.current, choiceIndex);
    } else {
      await ref.read(submitAnswerProvider)(s.current, choiceIndex);
    }
    state = AsyncData(s.copyWith(answers: answers));
    // 선택 즉시 세션에 반영 → 재진입 시 이 답·해설이 복원된다.
    _saveSession(s.index, answers, s.questions);
  }

  /// 다음 문항으로.
  /// - exam: 채점 없이 전진(마지막 문항은 submit으로만 종료).
  /// - normal 계열: 해설을 본 뒤에만 전진, 마지막이면 종료.
  void next() {
    final s = state.value;
    if (s == null || s.finished) return;

    if (s.isExam) {
      if (s.isLast) return;
      final nextIndex = s.index + 1;
      state = AsyncData(s.copyWith(index: nextIndex));
      _saveSession(nextIndex, s.answers, s.questions);
      return;
    }

    if (!s.revealed) return;
    if (s.isLast) {
      state = AsyncData(s.copyWith(finished: true));
      _clearSession();
    } else {
      final nextIndex = s.index + 1;
      state = AsyncData(s.copyWith(index: nextIndex));
      // 아직 안 푼 새 문항으로 나아갈 때만 이어풀기 위치를 전진 저장.
      // 뒤로 갔다 되돌아오는 중이면 최전방 위치를 유지한다.
      if (s.answers[nextIndex] == null) {
        _saveSession(nextIndex, s.answers, s.questions);
      }
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

    // 전 문항을 단일 배치로 채점·기록(문항별 순차 기록의 O(N²) 재집계 방지).
    final entries = [
      for (var i = 0; i < s.questions.length; i++)
        (question: s.questions[i], selectedIndex: s.answers[i] ?? -1),
    ];
    await ref.read(submitAnswerProvider).submitAll(entries);
    state = AsyncData(s.copyWith(finished: true));
    _clearSession();
  }

  /// ai 모드는 세션을 쓰지 않는다(문항별 응답 기록이 곧 진행 상태).
  void _saveSession(int index, List<int?> answers, List<Question> questions) {
    if (arg.mode == QuizMode.ai) return;
    ref.read(saveSessionPositionProvider)(
      arg.categoryId,
      arg.mode,
      lastIndex: index,
      answers: answers,
      questions: questions,
    );
  }

  void _clearSession() {
    if (arg.mode == QuizMode.ai) return;
    ref.read(clearSessionProvider)(arg.categoryId, arg.mode);
  }
}
