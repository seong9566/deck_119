import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/quiz_mode.dart';
import '../../../domain/entities/subject.dart';
import '../../quiz/view/quiz_page.dart';
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
          message: '콘텐츠를 불러오지 못했어요.\n$e',
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

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
          for (final (mode, icon, label, desc) in _modeInfo)
            ModeTile(
              icon: icon,
              label: label,
              description: desc,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizPage(subjectId: subject.id, mode: mode),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
