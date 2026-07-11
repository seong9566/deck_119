import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 문항 유형 배지(DESIGN_HANDOFF §2.2). selTint pill · labelStrong · textSecondary.
class TypeBadge extends StatelessWidget {
  final QuestionType type;
  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(
        color: c.selTint,
        borderRadius: appSmRadius,
      ),
      child: Text(
        type == QuestionType.ox ? 'OX' : '객관식',
        style: AppText.label.copyWith(color: c.textSecondary),
      ),
    );
  }
}
