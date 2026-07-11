import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/question_collection.dart';
import '../../app_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/home_view_model.dart';

/// 홈(DESIGN_HANDOFF §2.2). 로고 + 문제 세트 목록(원형 회차별·심화·전체).
/// 세트를 고르면 모드 선택 화면으로 이동한다. 하단 탭바는 셸이 제공.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(child: CollectionsView(showLogo: true)),
    );
  }
}

/// 문제 세트 목록. 홈과 과목 탭이 공유한다.
class CollectionsView extends ConsumerWidget {
  final bool showLogo;
  const CollectionsView({super.key, this.showLogo = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final async = ref.watch(collectionsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        iconColor: c.brand,
        iconBg: c.brandTint,
        title: '콘텐츠를 불러오지 못했어요',
        description: '문항 데이터를 여는 중 문제가 생겼어요.\n앱을 다시 실행해 주세요.',
      ),
      data: (all) {
        final wonhyeong = all.where((x) => x.group == '원형').toList();
        final simhwa = all.where((x) => x.group == '심화').toList();
        final jeonche = all.where((x) => x.group == '전체').toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.huge),
          children: [
            if (showLogo)
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
            Text('소방관계법규',
                style: AppText.titleScreen.copyWith(color: c.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text('풀 문제집을 선택하세요',
                style: AppText.caption.copyWith(color: c.textTertiary)),
            if (wonhyeong.isNotEmpty) ...[
              _SectionLabel('원형 · 동형모의고사'),
              for (final col in wonhyeong) _CollectionRow(col: col),
            ],
            if (simhwa.isNotEmpty) ...[
              _SectionLabel('심화'),
              for (final col in simhwa) _CollectionRow(col: col),
            ],
            if (jeonche.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              for (final col in jeonche) _CollectionRow(col: col),
            ],
          ],
        );
      },
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

class _CollectionRow extends ConsumerWidget {
  final QuestionCollection col;
  const _CollectionRow({required this.col});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 2,
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
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
