import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 진행 헤더(DESIGN_HANDOFF §2.2). 상단 라벨행(모드 · N/총 + 닫기✕) + brand 진행바.
/// [modeLabel]/[onClose]가 없으면 각각 생략(하위호환).
class ProgressHeader extends StatelessWidget {
  final int position;
  final int total;
  final double value;
  final String? modeLabel;
  final VoidCallback? onClose;

  const ProgressHeader({
    super.key,
    required this.position,
    required this.total,
    required this.value,
    this.modeLabel,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: AppText.label
                      .copyWith(color: c.textSecondary, letterSpacing: 0),
                  children: [
                    if (modeLabel != null) TextSpan(text: '$modeLabel  '),
                    TextSpan(
                      text:
                          '${modeLabel != null ? '· ' : ''}$position / $total',
                      style: AppText.caption.copyWith(color: c.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: c.textTertiary,
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                tooltip: '닫기',
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: appPillRadius,
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: c.brand,
            backgroundColor: c.selTint,
          ),
        ),
      ],
    );
  }
}
