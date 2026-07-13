import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 채점 직후 정오답 배너(DESIGN_HANDOFF §2.2). tint 배경 + 경계 + 아이콘 원형 배지.
/// 해설이 붙지 않는 단독 사용처를 위한 컴포넌트(붙은 형태는 [ExplanationCard]).
class AnswerBanner extends StatelessWidget {
  final bool correct;
  const AnswerBanner({super.key, required this.correct});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = correct ? c.onCorrect : c.onWrong;
    final border = correct ? c.correct : c.wrong;
    final ink = correct ? c.correctInk : c.wrongInk;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: tint,
        border: Border.all(color: border, width: 1.5),
        borderRadius: appTileRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: border, shape: BoxShape.circle),
            child: Icon(correct ? Icons.check : Icons.close,
                size: 15, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(correct ? '정답입니다' : '오답입니다',
              style: AppText.choice.copyWith(color: ink, fontSize: 14)),
        ],
      ),
    );
  }
}
