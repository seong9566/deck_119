import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 빈/안내 상태(DESIGN_HANDOFF §2.2). 88 아이콘 칩(radius iconBadge) + 제목 + 설명.
/// [iconColor]/[iconBg]로 정답(초록)·에러(brand) 등 톤 지정(기본 중립).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color? iconColor;
  final Color? iconBg;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg ?? c.selTint,
                borderRadius: BorderRadius.circular(AppRadius.iconBadge),
              ),
              child: Icon(icon, size: 38, color: iconColor ?? c.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xl + 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.choice
                  .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: AppText.caption
                    .copyWith(color: c.textSecondary, height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
