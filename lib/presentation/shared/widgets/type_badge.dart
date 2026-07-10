import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 문항 유형 배지(UI_DESIGN_SYSTEM §5). mcq="객관식"(중립) / ox="OX"(brand 외곽선).
class TypeBadge extends StatelessWidget {
  final QuestionType type;
  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isOx = type == QuestionType.ox;
    final color = isOx ? c.brand : c.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: appPillRadius,
        border: Border.all(color: color),
      ),
      child: Text(
        isOx ? 'OX' : '객관식',
        style: AppText.label.copyWith(color: color),
      ),
    );
  }
}
