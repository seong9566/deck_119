import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 선택지 타일 상태(UI_DESIGN_SYSTEM §5).
enum ChoiceStatus {
  /// 기본.
  idle,

  /// 채점 전 선택(brand 링).
  selected,

  /// 채점 후 정답.
  correct,

  /// 채점 후 내가 고른 오답.
  wrong,
}

/// 선택지 타일(UI_DESIGN_SYSTEM §5). 전폭·최소높이 52·좌측정렬. 정답/오답은
/// 색 + 아이콘(✓/✕) 3중 신호. onTap이 null이면 비활성(채점 후).
class ChoiceTile extends StatelessWidget {
  final String label;
  final ChoiceStatus status;
  final VoidCallback? onTap;

  const ChoiceTile({
    super.key,
    required this.label,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg, Color border, IconData? icon) = switch (status) {
      ChoiceStatus.idle => (c.surface, c.textPrimary, c.outline, null),
      ChoiceStatus.selected => (c.surface, c.textPrimary, c.selectedRing, null),
      ChoiceStatus.correct => (c.correct, c.onCorrect, c.correct, Icons.check),
      ChoiceStatus.wrong => (c.wrong, c.onWrong, c.wrong, Icons.close),
    };
    final borderWidth = status == ChoiceStatus.selected ? 2.0 : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: bg,
        borderRadius: appMdRadius,
        child: InkWell(
          borderRadius: appMdRadius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: appMdRadius,
              border: Border.all(color: border, width: borderWidth),
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(label,
                        style: AppText.choice.copyWith(color: fg)),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(icon, size: 20, color: fg),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
