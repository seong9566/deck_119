import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 홈 모드 진입 타일(DESIGN_HANDOFF §2.2). 2×2 그리드 셀: 아이콘(brand) + 제목 +
/// 설명, min-height 112, radius tile, 미세 그림자. [highlighted]면 brandTint 강조.
class ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;
  final bool highlighted;

  const ModeTile({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: highlighted ? c.brandTint : c.surface,
      borderRadius: appTileRadius,
      child: InkWell(
        borderRadius: appTileRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appTileRadius,
            border: Border.all(
              color: highlighted ? c.brand : c.outline,
              width: highlighted ? 1.5 : 1,
            ),
            boxShadow: highlighted ? null : appCardShadow(c),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: c.brand, size: 24),
                const SizedBox(height: AppSpacing.md),
                Text(label,
                    style: AppText.choice
                        .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs - 1),
                Text(description,
                    style: AppText.caption
                        .copyWith(color: c.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
