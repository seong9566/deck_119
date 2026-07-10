import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 홈 모드 진입 타일(UI_DESIGN_SYSTEM §5). 아이콘 + 라벨 + 짧은 설명.
/// [highlighted]면 이어풀기 강조(brand 외곽선 + surfaceVariant 배경).
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
    final accent = highlighted ? c.brand : c.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: highlighted ? c.surfaceVariant : c.surface,
        borderRadius: appMdRadius,
        child: InkWell(
          borderRadius: appMdRadius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: appMdRadius,
              border: Border.all(
                color: highlighted ? c.brand : c.outline,
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(icon, color: accent),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppText.choice.copyWith(color: c.textPrimary)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(description,
                            style:
                                AppText.caption.copyWith(color: c.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: c.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
