import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 진행 헤더(UI_DESIGN_SYSTEM §5). 진행바(brand) + 우측 `N / 총` 라벨.
class ProgressHeader extends StatelessWidget {
  final int position;
  final int total;
  final double value;

  const ProgressHeader({
    super.key,
    required this.position,
    required this.total,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: appPillRadius,
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              color: c.brand,
              backgroundColor: c.surfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('$position / $total',
            style: AppText.label.copyWith(color: c.textSecondary)),
      ],
    );
  }
}
