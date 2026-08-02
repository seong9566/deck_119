import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../di.dart';
import '../../../domain/entities/ai_quiz_set.dart';
import '../../../domain/entities/progress_stats.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../../ai_gen/viewmodel/ai_generation_controller.dart';
import '../../ai_gen/viewmodel/ai_gen_view_model.dart';
import '../../app_router.dart';
import '../../quiz/view/quiz_page.dart' show modeTitle;
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/home_view_model.dart';

/// 홈(DESIGN_HANDOFF §2.2) — 학습 대시보드.
/// 이어풀기 + 오늘의 학습(랜덤·오답) + 진척(정답률·연속학습·진행률).
/// 특정 문제집을 고르는 탐색은 '과목' 탭이 담당한다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _refresh(WidgetRef ref, String collectionId) {
    // 대시보드 3종은 StreamProvider라 자동 갱신, resumeInfoProvider만 프리워밍.
    ref.invalidate(resumeInfoProvider(collectionId));
  }

  Future<void> _openResume(
      BuildContext context, WidgetRef ref, RecentSessionCard card) async {
    // 세션이 어떤 모드였든 그 모드로 되돌아가야 저장된 세트가 복원된다.
    await context
        .push(Routes.quizLink(card.collectionId, card.mode, resume: true));
    _refresh(ref, card.collectionId);
  }

  Future<void> _openMode(BuildContext context, WidgetRef ref, String categoryId,
      QuizMode mode) async {
    await context.push(Routes.quizLink(categoryId, mode));
    _refresh(ref, categoryId);
  }

  /// AI 문제함 재풀이 — 누적 문항 + 기존 응답을 합쳐 핸드오프 홀더에 주입 후 ai 모드로.
  /// 이미 푼 문항이 있으면 이어풀기/처음부터를 먼저 묻는다.
  Future<void> _openAiBank(BuildContext context, WidgetRef ref) async {
    const subjectId = 'fire-law';
    var set = await ref.read(getAiQuizSetProvider)(subjectId);
    if (set.isEmpty || !context.mounted) return;

    if (set.solvedCount > 0) {
      final choice = await _askAiStart(context, set);
      if (choice == null || !context.mounted) return;
      if (choice == _AiStart.restart) {
        await ref.read(resetAiAnswersProvider)(subjectId);
        set = set.reset;
      }
    }
    if (!context.mounted) return;
    ref.read(aiQuizSetProvider.notifier).state = set;
    await context.push(Routes.quizLink(subjectId, QuizMode.ai));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final collectionsAsync = ref.watch(categoriesProvider);
    final aiGenerating = ref.watch(aiGenerationControllerProvider) != null;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: collectionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline,
            iconColor: c.brand,
            iconBg: c.brandTint,
            title: '콘텐츠를 불러오지 못했어요',
            description: '문항 데이터를 여는 중 문제가 생겼어요.\n앱을 다시 실행해 주세요.',
          ),
          data: (collections) {
            // '전체' 세트 = 과목 전체(랜덤·오답 대상 + 진행률 분모).
            final jeonche = collections.firstWhere(
              (x) => x.group == '전체',
              orElse: () => collections.last,
            );
            final categoryId = jeonche.id;
            final total = jeonche.count;

            final stats =
                ref.watch(progressStatsProvider).valueOrNull ?? ProgressStats.empty;
            final wrongCount = ref.watch(wrongCountProvider).valueOrNull ?? 0;
            final aiBankCount = ref.watch(aiBankCountProvider).valueOrNull ?? 0;
            final aiUnsolvedCount =
                ref.watch(aiUnsolvedCountProvider).valueOrNull ?? 0;
            // 홈 진입 시 회수 안전망 실행(타임아웃으로 못 받았던 완료분 흡수).
            ref.watch(aiRecoveryProvider);
            final recent = ref.watch(recentSessionCardProvider).valueOrNull;

            return ResponsiveBody(
              child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.huge),
              children: [
                if (aiGenerating) ...[
                  const _AiGeneratingNotice(),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text.rich(
                    TextSpan(
                      style: AppText.logo.copyWith(color: c.textPrimary),
                      children: [
                        const TextSpan(text: '119'),
                        TextSpan(text: '덱', style: TextStyle(color: c.brand)),
                      ],
                    ),
                  ),
                ),
                _Greeting(streak: stats.streakDays),
                const SizedBox(height: AppSpacing.xl),
                if (recent != null)
                  _ResumeCard(
                    card: recent,
                    onTap: () => _openResume(context, ref, recent),
                  )
                else
                  _StartPrompt(onTap: () => context.go(Routes.subjects)),
                _SectionLabel('오늘의 학습'),
                Row(
                  children: [
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.bolt,
                        title: '빠른 10문제',
                        subtitle: '무작위 10문항',
                        onTap: () => _openMode(
                            context, ref, categoryId, QuizMode.quick),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.replay,
                        title: '오답 재풀이',
                        subtitle: wrongCount > 0 ? '$wrongCount문제' : '없음',
                        enabled: wrongCount > 0,
                        onTap: () => _openMode(
                            context, ref, categoryId, QuizMode.review),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _AiGenEntry(onTap: () => context.push(Routes.aiGen)),
                if (aiBankCount > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  _AiBankEntry(
                    count: aiBankCount,
                    unsolved: aiUnsolvedCount,
                    onTap: () => _openAiBank(context, ref),
                  ),
                ],
                _SectionLabel('내 진척'),
                _ProgressCard(
                  stats: stats,
                  total: total,
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(Routes.subjects),
                    child: Text('문제집 전체 보기 →',
                        style:
                            AppText.caption.copyWith(color: c.brandInk)),
                  ),
                ),
              ],
            ),
            );
          },
        ),
      ),
    );
  }
}

/// AI 문제함 시작 방식.
enum _AiStart { resume, restart }

/// 이어풀기/처음부터 확인. 이미 다 푼 상태면 이어풀기 선택지를 숨긴다.
Future<_AiStart?> _askAiStart(BuildContext context, AiQuizSet set) {
  final c = context.colors;
  final allSolved = set.unsolvedCount == 0;
  return showDialog<_AiStart>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      title: Text(allSolved ? '문제를 모두 풀었어요' : '이어서 풀까요?',
          style: AppText.choice
              .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
      content: Text(
        allSolved
            ? '${set.total}문항을 모두 풀었어요.\n처음부터 다시 풀면 기존 풀이 기록은 지워져요.'
            : '${set.total}문항 중 ${set.solvedCount}문항을 풀었어요.\n'
                '처음부터 다시 풀면 기존 풀이 기록은 지워져요.',
        style: AppText.caption.copyWith(color: c.textSecondary, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('닫기', style: TextStyle(color: c.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, _AiStart.restart),
          child: Text('처음부터 다시', style: TextStyle(color: c.textSecondary)),
        ),
        if (!allSolved)
          TextButton(
            onPressed: () => Navigator.pop(ctx, _AiStart.resume),
            child: Text('이어풀기',
                style:
                    TextStyle(color: c.brand, fontWeight: FontWeight.w700)),
          ),
      ],
    ),
  );
}

class _AiGeneratingNotice extends StatelessWidget {
  const _AiGeneratingNotice();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: c.brandTint,
        border: Border.all(color: c.brand),
        borderRadius: appTileRadius,
      ),
      child: Text(
        '🔄 AI 문제 생성 중…',
        style: AppText.caption.copyWith(color: c.brandInk),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final int streak;
  const _Greeting({required this.streak});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text('안녕하세요 👋',
              style: AppText.titleScreen.copyWith(color: c.textPrimary)),
        ),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: c.brandTint,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: c.brand),
            ),
            child: Text('🔥 연속 $streak일',
                style: AppText.label.copyWith(color: c.brandInk)),
          ),
      ],
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final RecentSessionCard card;
  final VoidCallback onTap;
  const _ResumeCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratio = card.total == 0 ? 0.0 : card.position / card.total;
    return Material(
      color: c.brandTint,
      borderRadius: appMdRadius,
      child: InkWell(
        borderRadius: appMdRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appMdRadius,
            border: Border.all(color: c.brand, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이어풀기 · ${modeTitle(card.mode)}',
                    style: AppText.label
                        .copyWith(color: c.brandInk, letterSpacing: 0.9)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(card.name,
                          style: AppText.subjectName
                              .copyWith(color: c.textPrimary)),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.brand,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: c.outline,
                    valueColor: AlwaysStoppedAnimation(c.brand),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('${card.position} / ${card.total} 문항',
                    style: AppText.caption.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 학습 기록이 없을 때(세션 없음) — 과목 탭으로 유도.
class _StartPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _StartPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: appMdRadius,
      child: InkWell(
        borderRadius: appMdRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appMdRadius,
            border: Border.all(color: c.outline),
            boxShadow: appCardShadow(c),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg + 2),
            child: Row(
              children: [
                Icon(Icons.menu_book_outlined, color: c.brand),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('학습을 시작해 보세요',
                          style: AppText.choice.copyWith(
                              color: c.textPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('과목에서 문제집을 골라 첫 세션을 시작하면 여기 이어풀기가 떠요',
                          style: AppText.caption
                              .copyWith(color: c.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = enabled ? c.textPrimary : c.textTertiary;
    return Material(
      color: c.surface,
      borderRadius: appTileRadius,
      child: InkWell(
        borderRadius: appTileRadius,
        onTap: enabled ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appTileRadius,
            border: Border.all(color: c.outline),
            boxShadow: appCardShadow(c),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: enabled ? c.brand : c.textTertiary, size: 26),
                const SizedBox(height: AppSpacing.md),
                Text(title,
                    style: AppText.choice
                        .copyWith(color: fg, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppText.caption.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AI 문제 생성 진입(홈). 년도별 기출 기반 생성 → 참고용.
class _AiGenEntry extends StatelessWidget {
  final VoidCallback onTap;
  const _AiGenEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.brandTint,
      borderRadius: appTileRadius,
      child: InkWell(
        borderRadius: appTileRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appTileRadius,
            border: Border.all(color: c.brand),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: c.brand, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 문제 생성',
                          style: AppText.choice.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('년도별 기출 기반 · 참고용',
                          style: AppText.caption
                              .copyWith(color: c.brandInk)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.brand),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AI 문제함 진입(홈) — 적립된 AI 문항 누적 재풀이. 1개 이상일 때만 노출.
class _AiBankEntry extends StatelessWidget {
  final int count;

  /// 아직 풀지 않은 문항 수(0이면 모두 푼 상태).
  final int unsolved;
  final VoidCallback onTap;
  const _AiBankEntry({
    required this.count,
    required this.unsolved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: appTileRadius,
      child: InkWell(
        borderRadius: appTileRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appTileRadius,
            border: Border.all(color: c.outline),
            boxShadow: appCardShadow(c),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: c.brand, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 문제함',
                          style: AppText.choice.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                          unsolved > 0
                              ? '누적 $count문항 · 미풀이 $unsolved문항'
                              : '누적 $count문항 · 모두 풀었어요',
                          style: AppText.caption
                              .copyWith(color: c.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ProgressStats stats;
  final int total;
  const _ProgressCard({required this.stats, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratio =
        total == 0 ? 0.0 : (stats.distinctAttempted / total).clamp(0.0, 1.0);
    final pct = (ratio * 100).round();
    final acc = stats.accuracy;
    final accText = acc == null ? '—' : '${(acc * 100).round()}%';

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appTileRadius,
        border: Border.all(color: c.outline),
        boxShadow: appCardShadow(c),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('진행률',
                    style: AppText.label.copyWith(color: c.textTertiary)),
              ),
              Text('$pct%',
                  style: AppText.choice.copyWith(
                      color: c.textPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: c.background,
              valueColor: AlwaysStoppedAnimation(c.brand),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('${stats.distinctAttempted} / $total 문항 학습',
              style: AppText.caption.copyWith(color: c.textSecondary)),
          const Divider(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: _Metric(label: '정답률', value: accText),
              ),
              Container(width: 1, height: 32, color: c.outline),
              Expanded(
                child: _Metric(label: '푼 문제', value: '${stats.attempts}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Text(value,
            style: AppText.subjectName.copyWith(color: c.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: AppText.caption.copyWith(color: c.textTertiary)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs, AppSpacing.xxl, AppSpacing.xs, AppSpacing.md),
      child: Text(text,
          style: AppText.label
              .copyWith(color: c.textTertiary, letterSpacing: 0.3)),
    );
  }
}
