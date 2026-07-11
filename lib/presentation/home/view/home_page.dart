import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/quiz_mode.dart';
import '../../../domain/entities/subject.dart';
import '../../app_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(homeViewModelProvider);

    return AppScaffold(
      title: '119덱',
      padBody: false,
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          iconColor: context.colors.brand,
          iconBg: context.colors.brandTint,
          title: '콘텐츠를 불러오지 못했어요',
          description: '문항 데이터를 여는 중 문제가 생겼어요.\n앱을 다시 실행해 주세요.',
        ),
        data: (subjects) => ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
          children: [
            for (final subject in subjects) _SubjectCard(subject: subject),
          ],
        ),
      ),
    );
  }
}

/// 홈에 노출할 모드 메타(아이콘·라벨·설명).
const _modeInfo = <(QuizMode, IconData, String, String)>[
  (QuizMode.normal, Icons.list_alt, '전체 풀이', '25문항 순서대로'),
  (QuizMode.random, Icons.shuffle, '랜덤', '무작위 출제'),
  (QuizMode.review, Icons.replay, '오답 재풀이', '틀린 문제만'),
  (QuizMode.exam, Icons.assignment_turned_in, '시험 모드', '제한시간 없이 일괄 채점'),
];

class _SubjectCard extends ConsumerWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});

  /// 풀이 화면으로 이동 후 돌아오면 이어풀기 정보를 새로 읽는다.
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appMdRadius,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject.name,
              style: AppText.titleScreen.copyWith(color: c.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          if (resume != null)
            ModeTile(
              icon: Icons.play_circle_outline,
              label: '이어풀기',
              description: '정규 · ${resume.position} / ${resume.total}',
              highlighted: true,
              onTap: () =>
                  _open(context, ref, QuizMode.normal, resume: true),
            ),
          for (final (mode, icon, label, desc) in _modeInfo)
            ModeTile(
              icon: icon,
              label: label,
              description: desc,
              onTap: () => _open(context, ref, mode),
            ),
        ],
      ),
    );
  }
}
