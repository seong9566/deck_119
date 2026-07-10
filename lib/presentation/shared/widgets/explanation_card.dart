import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 해설 카드(UI_DESIGN_SYSTEM §5). surfaceVariant 배경, "해설" 라벨 + 본문.
class ExplanationCard extends StatelessWidget {
  final String explanation;
  const ExplanationCard({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: c.surfaceVariant, borderRadius: appMdRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('해설', style: AppText.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(explanation, style: AppText.body.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}
