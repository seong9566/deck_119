import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/subject.dart';
import '../../app_router.dart';
import '../../home/viewmodel/home_view_model.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';

/// 과목 화면(DESIGN_HANDOFF §2.1/§2.2). 하단 탭 IA의 두 번째 탭.
/// 실재 과목만 렌더(§3-1). 선택 시 홈으로 복귀.
class SubjectsPage extends ConsumerWidget {
  const SubjectsPage({super.key});

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
          data: (subjects) => ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
            children: [
              Text('과목', style: AppText.titleScreen.copyWith(color: c.textPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Text('풀 과목을 선택하세요',
                  style: AppText.caption.copyWith(color: c.textTertiary)),
              const SizedBox(height: AppSpacing.xl),
              for (final subject in subjects)
                _SubjectRow(subject: subject, selected: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final Subject subject;
  final bool selected;
  const _SubjectRow({required this.subject, required this.selected});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: c.surface,
        borderRadius: appTileRadius,
        child: InkWell(
          borderRadius: appTileRadius,
          onTap: () => context.go(Routes.home),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: appTileRadius,
              border: Border.all(
                color: selected ? c.brand : c.outline,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: appCardShadow(c),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg + 2, AppSpacing.lg, AppSpacing.lg + 2, AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(subject.name,
                        style: AppText.choice.copyWith(
                            color: c.textPrimary, fontWeight: FontWeight.w700)),
                  ),
                  if (selected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecoration(color: c.brand, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          size: 15, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
