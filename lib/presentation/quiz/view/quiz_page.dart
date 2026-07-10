import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/question.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/quiz_state.dart';
import '../viewmodel/quiz_view_model.dart';

class QuizPage extends ConsumerWidget {
  final String subjectId;
  final QuizMode mode;

  /// normal 모드에서 마지막 위치부터 이어풀지 여부.
  final bool resume;
  const QuizPage({
    super.key,
    required this.subjectId,
    required this.mode,
    this.resume = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (subjectId: subjectId, mode: mode, resume: resume);
    final async = ref.watch(quizViewModelProvider(args));

    return async.when(
      loading: () => AppScaffold(
        title: modeTitle(mode),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        title: modeTitle(mode),
        body: EmptyState(icon: Icons.error_outline, message: '불러오기 실패\n$e'),
      ),
      data: (state) {
        if (state.isEmpty) {
          return AppScaffold(
            title: modeTitle(mode),
            body: const EmptyState(
              icon: Icons.inbox_outlined,
              message: '풀 오답이 없어요.\n먼저 문제를 풀어 오답을 쌓아보세요.',
            ),
          );
        }
        if (state.finished) {
          return _ResultView(
            state: state,
            onRetry: () => ref.invalidate(quizViewModelProvider(args)),
          );
        }
        return _QuestionView(args: args, state: state);
      },
    );
  }
}

String modeTitle(QuizMode mode) => switch (mode) {
      QuizMode.normal => '전체 풀이',
      QuizMode.random => '랜덤',
      QuizMode.review => '오답 재풀이',
      QuizMode.exam => '시험 모드',
    };

class _QuestionView extends ConsumerWidget {
  final QuizArgs args;
  final QuizState state;
  const _QuestionView({required this.args, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(quizViewModelProvider(args).notifier);
    final q = state.current;
    final correct = state.selected == q.answerIndex;

    return AppScaffold(
      title: modeTitle(args.mode),
      padBody: false,
      bottomBar: _bottomBar(vm),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            child: ProgressHeader(
              position: state.position,
              total: state.total,
              value: state.progress,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              children: [
                QuestionCard(
                  position: state.position,
                  total: state.total,
                  type: q.type,
                  stem: q.stem,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (var i = 0; i < q.choices.length; i++)
                  ChoiceTile(
                    label: q.choices[i],
                    status: _statusFor(i, q),
                    onTap: (state.isExam || !state.revealed)
                        ? () => vm.select(i)
                        : null,
                  ),
                if (state.revealed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AnswerBanner(correct: correct),
                  const SizedBox(height: AppSpacing.md),
                  ExplanationCard(explanation: q.explanation),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 액션. exam은 항상 다음/제출, normal 계열은 채점 후에만 노출.
  Widget? _bottomBar(QuizViewModel vm) {
    if (state.isExam) {
      return PrimaryButton(
        label: state.isLast ? '제출' : '다음',
        onPressed: state.isLast ? vm.submit : vm.next,
      );
    }
    return state.revealed
        ? PrimaryButton(
            label: state.isLast ? '결과 보기' : '다음',
            onPressed: vm.next,
          )
        : null;
  }

  ChoiceStatus _statusFor(int i, Question q) {
    if (state.isExam || !state.revealed) {
      return i == state.selected ? ChoiceStatus.selected : ChoiceStatus.idle;
    }
    if (i == q.answerIndex) return ChoiceStatus.correct;
    if (i == state.selected) return ChoiceStatus.wrong;
    return ChoiceStatus.idle;
  }
}

class _ResultView extends StatelessWidget {
  final QuizState state;
  final VoidCallback onRetry;
  const _ResultView({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final wrong = state.wrongIndexes;
    return AppScaffold(
      title: '결과',
      padBody: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        children: [
          ScoreView(correct: state.correctCount, total: state.total),
          const SizedBox(height: AppSpacing.xl),
          _ReviewLabel(wrongCount: wrong.length),
          const SizedBox(height: AppSpacing.md),
          if (wrong.isEmpty)
            const EmptyState(
              icon: Icons.emoji_events_outlined,
              message: '틀린 문제가 없어요. 완벽해요!',
            )
          else
            for (final i in wrong)
              ReviewCard(
                order: i + 1,
                stem: state.questions[i].stem,
                myAnswer: state.answers[i] == null
                    ? '미응답'
                    : state.questions[i].choices[state.answers[i]!],
                correctAnswer: state
                    .questions[i].choices[state.questions[i].answerIndex],
                explanation: state.questions[i].explanation,
              ),
        ],
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SecondaryButton(label: '다시 풀기', onPressed: onRetry),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: '홈으로',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

class _ReviewLabel extends StatelessWidget {
  final int wrongCount;
  const _ReviewLabel({required this.wrongCount});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      wrongCount == 0 ? '오답 리뷰' : '오답 리뷰 ($wrongCount)',
      style: AppText.label.copyWith(color: c.textSecondary),
    );
  }
}

