import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/question_collection.dart';
import '../../app_router.dart';
import '../../home/viewmodel/home_view_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';

/// 과목(문제집) 탐색 — 하단 탭 IA의 두 번째 탭.
/// 과목 선택 후 한 화면에 [회차별(원형)] + [난이도별(심화·전체)] 섹션을 보여준다.
/// (과목이 1개인 현재는 그 과목을 바로 펼친다.)
class SubjectsPage extends ConsumerWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final subjects = ref.watch(homeViewModelProvider).valueOrNull;
    final subjectName =
        (subjects != null && subjects.isNotEmpty) ? subjects.first.name : null;
    final async = ref.watch(collectionsProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline,
            iconColor: c.brand,
            iconBg: c.brandTint,
            title: '콘텐츠를 불러오지 못했어요',
            description: '문항 데이터를 여는 중 문제가 생겼어요.\n앱을 다시 실행해 주세요.',
          ),
          data: (all) {
            final rounds = all.where((x) => x.group == '원형').toList();
            final difficulty =
                all.where((x) => x.group == '심화' || x.group == '전체').toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.huge),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('과목',
                      style: AppText.label.copyWith(
                          color: c.textTertiary, letterSpacing: 0.3)),
                ),
                Text(subjectName ?? '소방관계법규',
                    style:
                        AppText.titleScreen.copyWith(color: c.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('회차별 또는 난이도별로 문제집을 선택하세요',
                    style: AppText.caption.copyWith(color: c.textTertiary)),
                if (rounds.isNotEmpty) ...[
                  _SectionLabel('회차별 · 원형(동형모의고사)'),
                  for (final col in rounds) _CollectionRow(col: col),
                ],
                if (difficulty.isNotEmpty) ...[
                  _SectionLabel('난이도별'),
                  for (final col in difficulty) _CollectionRow(col: col),
                ],
              ],
            );
          },
        ),
      ),
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

class _CollectionRow extends StatelessWidget {
  final QuestionCollection col;
  const _CollectionRow({required this.col});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final emphasize = col.group != '원형';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: c.surface,
        borderRadius: appTileRadius,
        child: InkWell(
          borderRadius: appTileRadius,
          onTap: () => context.push(Routes.setLink(col.id, col.name)),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: appTileRadius,
              border: Border.all(
                color: emphasize ? c.brand : c.outline,
                width: emphasize ? 1.5 : 1,
              ),
              boxShadow: appCardShadow(c),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg + 2, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(col.name,
                            style: AppText.choice
                                .copyWith(color: c.textPrimary, fontSize: 17)),
                        const SizedBox(height: 3),
                        Text('${col.count}문항',
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
      ),
    );
  }
}
