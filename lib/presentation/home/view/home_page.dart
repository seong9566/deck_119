import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/progress_stats.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../../app_router.dart';
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
    ref.invalidate(recentSessionCardProvider);
    ref.invalidate(progressStatsProvider);
    ref.invalidate(wrongCountProvider);
    ref.invalidate(resumeInfoProvider(collectionId));
  }

  Future<void> _openResume(
      BuildContext context, WidgetRef ref, RecentSessionCard card) async {
    await context.push(
        Routes.quizLink(card.collectionId, QuizMode.normal, resume: true));
    _refresh(ref, card.collectionId);
  }

  Future<void> _openMode(BuildContext context, WidgetRef ref, String subjectId,
      QuizMode mode) async {
    await context.push(Routes.quizLink(subjectId, mode));
    _refresh(ref, subjectId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final collectionsAsync = ref.watch(collectionsProvider);

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
            final subjectId = jeonche.id;
            final total = jeonche.count;

            final stats =
                ref.watch(progressStatsProvider).valueOrNull ?? ProgressStats.empty;
            final wrongCount = ref.watch(wrongCountProvider).valueOrNull ?? 0;
            final recent = ref.watch(recentSessionCardProvider).valueOrNull;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.huge),
              children: [
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
                            context, ref, subjectId, QuizMode.quick),
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
                            context, ref, subjectId, QuizMode.review),
                      ),
                    ),
                  ],
                ),
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
            );
          },
        ),
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
                Text('이어풀기',
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
