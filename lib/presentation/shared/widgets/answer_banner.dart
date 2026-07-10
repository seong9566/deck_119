import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 채점 직후 정오답 배너(UI_DESIGN_SYSTEM §5). 색 + 아이콘 동시.
class AnswerBanner extends StatelessWidget {
  final bool correct;
  const AnswerBanner({super.key, required this.correct});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = correct ? c.correct : c.wrong;
    final fg = correct ? c.onCorrect : c.onWrong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: appMdRadius),
      child: Row(
        children: [
          Icon(correct ? Icons.check_circle : Icons.cancel, size: 20, color: fg),
          const SizedBox(width: AppSpacing.sm),
          Text(correct ? '정답입니다' : '오답입니다',
              style: AppText.choice.copyWith(color: fg)),
        ],
      ),
    );
  }
}
