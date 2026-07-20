import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/question.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../../app_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/quiz_state.dart';
import '../viewmodel/quiz_view_model.dart';

class QuizPage extends ConsumerWidget {
  final String categoryId;
  final QuizMode mode;

  /// normal 모드에서 마지막 위치부터 이어풀지 여부.
  final bool resume;
  const QuizPage({
    super.key,
    required this.categoryId,
    required this.mode,
    this.resume = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (categoryId: categoryId, mode: mode, resume: resume);
    final async = ref.watch(quizViewModelProvider(args));

    return async.when(
      loading: () => const _QuizScaffold(child: _LoadingView()),
      error: (e, _) => _QuizScaffold(
        child: _ErrorView(
          onRetry: () => ref.invalidate(quizViewModelProvider(args)),
        ),
      ),
      data: (state) {
        if (state.isEmpty) {
          return _QuizScaffold(
            child: _EmptyReviewView(onHome: () => _closeToHome(context)),
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

/// 풀스크린 닫기(✕/홈으로) — push 진입이면 pop, 아니면 홈 탭으로.
void _closeToHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

/// 풀이 중 나가기 확인 — "그만 풀기"를 누르면 종료(뒤로가기 아님).
Future<void> _confirmExit(BuildContext context) async {
  final c = context.colors;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      title: Text('문제 그만 풀기',
          style: AppText.choice
              .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
      content: Text('지금 나가면 풀던 문제가 끝나요.\n그만 풀까요?',
          style: AppText.caption.copyWith(color: c.textSecondary, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('계속 풀기', style: TextStyle(color: c.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('그만 풀기',
              style: TextStyle(color: c.brand, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) _closeToHome(context);
}

/// 풀이·시험·로딩·에러 공용 풀스크린 셸(탭바 없음, 배경 background).
class _QuizScaffold extends StatelessWidget {
  final Widget child;
  const _QuizScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(child: ResponsiveBody(child: child)),
    );
  }
}

/// 로딩 — 스켈레톤 + 하단 스피너(DESIGN_HANDOFF §2.2).
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget bar(double h, {double? w, double top = 0}) => Container(
          margin: EdgeInsets.only(top: top),
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: c.selTint,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
                value: .28,
                minHeight: 6,
                color: c.brand,
                backgroundColor: c.selTint),
          ),
          const SizedBox(height: AppSpacing.xl),
          bar(22, w: 88),
          bar(22, top: AppSpacing.lg),
          bar(22, w: 220, top: AppSpacing.sm),
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xl),
            height: 120,
            decoration: BoxDecoration(
              color: c.surfaceVariant,
              border: Border.all(color: c.outline),
              borderRadius: BorderRadius.circular(AppRadius.tile),
            ),
          ),
          bar(56, top: AppSpacing.xl),
          bar(56, top: AppSpacing.sm),
          const Spacer(),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: c.brand),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('문항을 불러오는 중…',
                    style: AppText.caption.copyWith(color: c.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 에러 — brandTint "!" + 오프라인 번들 카피(§3-2) + 홈으로/다시 시도.
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: Icons.priority_high,
            iconColor: c.brand,
            iconBg: c.brandTint,
            title: '문제를 불러오지 못했어요',
            description: '문항 데이터를 여는 중 문제가 생겼어요.\n다시 시도해 주세요.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                    label: '홈으로', onPressed: () => _closeToHome(context)),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: PrimaryButton(label: '다시 시도', onPressed: onRetry),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 오답 재풀이 빈 상태(DESIGN_HANDOFF §2.2).
class _EmptyReviewView extends StatelessWidget {
  final VoidCallback onHome;
  const _EmptyReviewView({required this.onHome});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: Icons.check,
            iconColor: c.correct,
            iconBg: c.onCorrect,
            title: '풀 오답이 없어요',
            description: '틀린 문항을 모두 정복했어요.\n새 문제로 실력을 이어가 볼까요?',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          child: PrimaryButton(label: '홈으로', onPressed: onHome),
        ),
      ],
    );
  }
}

String modeTitle(QuizMode mode) => switch (mode) {
      QuizMode.normal => '전체 풀이',
      QuizMode.random => '랜덤',
      QuizMode.quick => '빠른 10문제',
      QuizMode.review => '오답 재풀이',
      QuizMode.exam => '시험 모드',
      QuizMode.ai => 'AI 생성',
    };

/// AI 생성 문항 상단 고지(ADR-0002 필수). "AI 생성·참고용" 배지 + 권장 문구.
class _AiReferenceNotice extends StatelessWidget {
  const _AiReferenceNotice();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 1),
      decoration: BoxDecoration(
        color: c.brandTint,
        border: Border.all(color: c.brand),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 15, color: c.brandInk),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'AI가 만든 문제입니다. 참고용으로만 활용하는 것을 권장해요.',
              style: AppText.caption.copyWith(color: c.brandInk),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionView extends ConsumerWidget {
  final QuizArgs args;
  final QuizState state;
  const _QuestionView({required this.args, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(quizViewModelProvider(args).notifier);
    final q = state.current;
    final correct = state.selected == q.answerIndex;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            ResponsiveBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
                child: ProgressHeader(
                  position: state.position,
                  total: state.total,
                  value: state.progress,
                  modeLabel: modeTitle(args.mode),
                  onClose: () => _confirmExit(context),
                ),
              ),
            ),
            Expanded(
              child: ResponsiveBody(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, AppSpacing.xl),
                  children: [
                    if (args.mode == QuizMode.ai) ...[
                      const _AiReferenceNotice(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    QuestionCard(type: q.type, stem: q.stem),
                    const SizedBox(height: AppSpacing.xl),
                    _choices(q, vm),
                    if (state.revealed) ...[
                      const SizedBox(height: AppSpacing.xl),
                      ExplanationCard(
                        correct: correct,
                        explanation: q.explanation,
                        breakdown: q.breakdown,
                        stem: q.stem,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _bottomBar(context, vm),
          ],
        ),
      ),
    );
  }

  /// 선택지 — MC는 세로 타일, OX는 대형 2버튼 행.
  Widget _choices(Question q, QuizViewModel vm) {
    final tappable = state.isExam || !state.revealed;
    if (q.type == QuestionType.ox) {
      return Row(
        children: [
          for (var i = 0; i < q.choices.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            ChoiceTile(
              label: q.choices[i],
              status: _statusFor(i, q),
              variant: ChoiceVariant.ox,
              onTap: tappable ? () => vm.select(i) : null,
            ),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < q.choices.length; i++)
          ChoiceTile(
            label: q.choices[i],
            status: _statusFor(i, q),
            onTap: tappable ? () => vm.select(i) : null,
          ),
      ],
    );
  }

  /// 하단 고정 버튼(항상 표시). normal은 채점 전 비활성(§목업 nextDisabled).
  Widget _bottomBar(BuildContext context, QuizViewModel vm) {
    final c = context.colors;
    final String label;
    final VoidCallback? onPressed;
    if (state.isExam) {
      label = state.isLast ? '제출하고 채점' : '다음';
      onPressed = state.isLast ? vm.submit : vm.next;
    } else {
      label = state.isLast ? '결과 보기' : '다음';
      onPressed = state.revealed ? vm.next : null; // 채점 전 비활성
    }
    final primary = PrimaryButton(label: label, onPressed: onPressed);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md - 2, AppSpacing.xl, AppSpacing.lg),
          child: ResponsiveBody(
            child: state.canGoPrev
                ? Row(
                    children: [
                      Expanded(
                        child:
                            SecondaryButton(label: '이전', onPressed: vm.prev),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(flex: 3, child: primary),
                    ],
                  )
                : primary,
          ),
        ),
      ),
    );
  }

  ChoiceStatus _statusFor(int i, Question q) {
    if (state.isExam || !state.revealed) {
      return i == state.selected ? ChoiceStatus.selected : ChoiceStatus.idle;
    }
    if (i == q.answerIndex) return ChoiceStatus.correct;
    if (i == state.selected) return ChoiceStatus.wrong;
    return ChoiceStatus.dimmed;
  }
}

class _ResultView extends StatelessWidget {
  final QuizState state;
  final VoidCallback onRetry;
  const _ResultView({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wrong = state.wrongIndexes;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바: 채점 결과 + 닫기
            ResponsiveBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
                child: Row(
                  children: [
                    Text('채점 결과',
                        style: AppText.label.copyWith(
                            color: c.textSecondary, letterSpacing: 0)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _closeToHome(context),
                      icon: const Icon(Icons.close),
                      color: c.textTertiary,
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: '닫기',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ResponsiveBody(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: ScoreView(
                          correct: state.correctCount, total: state.total),
                    ),
                    if (wrong.isEmpty)
                      const _PerfectCard()
                    else ...[
                      _ReviewHeader(count: wrong.length),
                      const SizedBox(height: AppSpacing.md),
                      for (final i in wrong)
                        ReviewCard(
                          order: i + 1,
                          stem: state.questions[i].stem,
                          myAnswer: state.answers[i] == null
                              ? '미응답'
                              : state.questions[i].choices[state.answers[i]!],
                          correctAnswer: state.questions[i]
                              .choices[state.questions[i].answerIndex],
                          explanation: state.questions[i].explanation,
                          breakdown: state.questions[i].breakdown,
                        ),
                    ],
                  ],
                ),
              ),
            ),
            // 하단 고정: 홈으로 / 다시 풀기
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.outline)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl,
                      AppSpacing.md - 2, AppSpacing.xl, AppSpacing.lg),
                  child: ResponsiveBody(
                    child: Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                              label: '홈으로',
                              onPressed: () => _closeToHome(context)),
                        ),
                        const SizedBox(width: AppSpacing.sm + 2),
                        Expanded(
                          flex: 3,
                          child: PrimaryButton(
                              label: state.mode == QuizMode.quick
                                  ? '다시 10문제'
                                  : '다시 풀기',
                              onPressed: onRetry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 결과 오답 리뷰 섹션 헤더: "오답 리뷰" + "N문항" pill.
class _ReviewHeader extends StatelessWidget {
  final int count;
  const _ReviewHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Text('오답 리뷰',
            style: AppText.choice
                .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md - 2, vertical: 3),
          decoration: BoxDecoration(
              color: c.onWrong,
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          child: Text('$count문항',
              style: AppText.caption
                  .copyWith(color: c.wrongInk, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

/// 만점 카드(correctTint) — 오답 대신 표시.
class _PerfectCard extends StatelessWidget {
  const _PerfectCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: c.onCorrect,
        border: Border.all(color: c.correct),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Text('전부 맞혔어요, 완벽합니다',
              textAlign: TextAlign.center,
              style: AppText.choice.copyWith(
                  color: c.correctInk, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs + 2),
          Text('복습할 오답이 없습니다. 다음 세트로 넘어가세요.',
              textAlign: TextAlign.center,
              style: AppText.caption
                  .copyWith(color: c.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
