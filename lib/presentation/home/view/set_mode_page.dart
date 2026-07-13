import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/quiz_mode.dart';
import '../../../domain/entities/resume_info.dart';
import '../../app_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/home_view_model.dart';

/// 세트(문제집) 하나에 대한 모드 선택 화면. 홈에서 세트를 고르면 push된다.
/// 세션·통계는 [collectionId]로 세트별 분리된다.
class SetModePage extends ConsumerWidget {
  final String collectionId;
  final String title;
  const SetModePage({super.key, required this.collectionId, required this.title});

  Future<void> _open(BuildContext context, WidgetRef ref, QuizMode mode,
      {bool resume = false}) async {
    final link = mode == QuizMode.exam
        ? Routes.examLink(collectionId)
        : Routes.quizLink(collectionId, mode, resume: resume);
    await context.push(link);
    ref.invalidate(resumeInfoProvider(collectionId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final stats = ref.watch(subjectStatsProvider(collectionId)).valueOrNull;
    final resume = ref.watch(resumeInfoProvider(collectionId)).valueOrNull;
    final total = stats?.total ?? 0;

    final modes = <(QuizMode, IconData, String, String)>[
      (QuizMode.normal, Icons.format_list_numbered, '전체 풀이', '1번부터 순서대로'),
      (QuizMode.random, Icons.shuffle, '랜덤', '무작위 순서로'),
      (QuizMode.review, Icons.replay, '오답 재풀이', '틀린 문항만 반복'),
      (QuizMode.exam, Icons.timer_outlined,
          '시험 모드', total > 0 ? '$total문 일괄 채점' : '일괄 채점'),
    ];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        foregroundColor: c.textPrimary,
        title: Text(title,
            style: AppText.choice.copyWith(color: c.textPrimary, fontSize: 16)),
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveBody(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.huge),
          children: [
            _SetHeader(name: title, meta: stats?.meta),
            if (resume != null) ...[
              const SizedBox(height: AppSpacing.md + 2),
              _ContinueTile(
                resume: resume,
                onTap: () => _open(context, ref, QuizMode.normal, resume: true),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs, AppSpacing.xxl, AppSpacing.xs, AppSpacing.md),
              child: Text('풀이 모드',
                  style: AppText.label
                      .copyWith(color: c.textTertiary, letterSpacing: 0.3)),
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
        ),
        ),
      ),
    );
  }
}

class _SetHeader extends StatelessWidget {
  final String name;
  final String? meta;
  const _SetHeader({required this.name, required this.meta});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
              Container(width: 8, height: 8, color: c.brand),
              const SizedBox(width: AppSpacing.sm),
              Text('선택한 문제집',
                  style: AppText.label
                      .copyWith(color: c.brandInk, letterSpacing: 0.9)),
            ],
          ),
          const SizedBox(height: AppSpacing.md - 2),
          Text(name,
              style: AppText.subjectName.copyWith(color: c.textPrimary)),
          if (meta != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(meta!,
                style: AppText.caption
                    .copyWith(color: c.textSecondary, fontSize: 13)),
          ],
        ],
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
                      Text('${resume.position} / ${resume.total} 이어서 풀기',
                          style: AppText.choice.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
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
