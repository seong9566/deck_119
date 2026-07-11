import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/quiz_mode.dart';
import '../../../domain/entities/resume_info.dart';
import '../../../domain/entities/subject.dart';
import '../../app_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/home_view_model.dart';

/// 홈(DESIGN_HANDOFF §2.2). 로고 · 선택한 과목 카드 · 이어풀기 · 모드 2×2 그리드.
/// 앱바 없이 로고를 본문 상단에 둔다(목업). 하단 탭바는 셸이 제공.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final subjectsAsync = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: subjectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline,
            iconColor: c.brand,
            iconBg: c.brandTint,
            title: '콘텐츠를 불러오지 못했어요',
            description: '문항 데이터를 여는 중 문제가 생겼어요.\n앱을 다시 실행해 주세요.',
          ),
          data: (subjects) {
            if (subjects.isEmpty) {
              return const EmptyState(
                icon: Icons.inbox_outlined,
                title: '과목이 없어요',
              );
            }
            return _HomeBody(subject: subjects.first);
          },
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  final Subject subject;
  const _HomeBody({required this.subject});

  Future<void> _open(BuildContext context, WidgetRef ref, QuizMode mode,
      {bool resume = false}) async {
    final link = mode == QuizMode.exam
        ? Routes.examLink(subject.id)
        : Routes.quizLink(subject.id, mode, resume: resume);
    await context.push(link);
    ref.invalidate(resumeInfoProvider(subject.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final resume = ref.watch(resumeInfoProvider(subject.id)).valueOrNull;
    final stats = ref.watch(subjectStatsProvider(subject.id)).valueOrNull;
    final total = stats?.total ?? 0;

    final modes = <(QuizMode, IconData, String, String)>[
      (QuizMode.normal, Icons.format_list_numbered, '전체 풀이', '1번부터 순서대로'),
      (QuizMode.random, Icons.shuffle, '랜덤', '무작위 순서로'),
      (QuizMode.review, Icons.replay, '오답 재풀이', '틀린 문항만 반복'),
      (
        QuizMode.exam,
        Icons.timer_outlined,
        '시험 모드',
        total > 0 ? '$total문 일괄 채점' : '일괄 채점'
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.huge),
      children: [
        // 로고
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
        // 선택한 과목 카드
        _SelectedSubjectCard(
          name: subject.name,
          meta: stats?.meta,
          onTap: () => context.go(Routes.subjects),
        ),
        // 이어풀기
        if (resume != null) ...[
          const SizedBox(height: AppSpacing.md + 2),
          _ContinueTile(
            resume: resume,
            onTap: () => _open(context, ref, QuizMode.normal, resume: true),
          ),
        ],
        // 풀이 모드
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs, AppSpacing.xxl, AppSpacing.xs, AppSpacing.md),
          child: Text('풀이 모드',
              style: AppText.label.copyWith(
                  color: c.textTertiary, letterSpacing: 0.3)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 120,
          ),
          itemCount: modes.length,
          itemBuilder: (_, i) {
            final (mode, icon, label, desc) = modes[i];
            return ModeTile(
              icon: icon,
              label: label,
              description: desc,
              onTap: () => _open(context, ref, mode),
            );
          },
        ),
      ],
    );
  }
}

class _SelectedSubjectCard extends StatelessWidget {
  final String name;
  final String? meta;
  final VoidCallback onTap;
  const _SelectedSubjectCard(
      {required this.name, required this.meta, required this.onTap});

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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, color: c.brand),
                    const SizedBox(width: AppSpacing.sm),
                    Text('선택한 과목',
                        style: AppText.label.copyWith(
                            color: c.brandInk, letterSpacing: 0.9)),
                    const Spacer(),
                    Text('전체 과목 →',
                        style: AppText.caption.copyWith(
                            color: c.textTertiary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md - 2),
                Text(name,
                    style: AppText.subjectName.copyWith(color: c.textPrimary)),
                if (meta != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(meta!,
                      style: AppText.caption.copyWith(
                          color: c.textSecondary, fontSize: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueTile extends StatelessWidget {
  final ResumeInfo resume;
  final VoidCallback onTap;
  const _ContinueTile({required this.resume, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg + 2, vertical: AppSpacing.lg),
            child: Row(
              children: [
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
                const SizedBox(width: AppSpacing.md + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이어풀기',
                          style: AppText.label.copyWith(
                              color: c.brandInk, letterSpacing: 0.9)),
                      const SizedBox(height: 2),
                      Text('정규 · ${resume.lastIndex} / ${resume.total} 이어서 풀기',
                          style: AppText.choice.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: c.brand, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
