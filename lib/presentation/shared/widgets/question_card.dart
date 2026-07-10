import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'type_badge.dart';

/// 문항 카드(UI_DESIGN_SYSTEM §5). 상단 라벨행(위치 N/총 + TypeBadge) + 지문(stem).
class QuestionCard extends StatelessWidget {
  final int position;
  final int total;
  final QuestionType type;
  final String stem;

  const QuestionCard({
    super.key,
    required this.position,
    required this.total,
    required this.type,
    required this.stem,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appMdRadius,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$position / $total',
                  style: AppText.label.copyWith(color: c.textSecondary)),
              const Spacer(),
              TypeBadge(type: type),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(stem, style: AppText.stem.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}
