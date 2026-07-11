import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 결과 점수 뷰(DESIGN_HANDOFF §2.2). 중앙 정렬: 결과 태그 · 56px 점수 " / 총" ·
/// 정답률 · 점수바. 만점이면 correct 강조, 그 외 brand.
class ScoreView extends StatelessWidget {
  final int correct;
  final int total;
  const ScoreView({super.key, required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final perfect = total > 0 && correct == total;

    final tagBg = perfect ? c.onCorrect : c.selTint;
    final tagFg = perfect ? c.correctInk : c.textSecondary;
    final tagText = perfect ? '만점 · 완벽' : '수고했어요';
    final tagIcon = perfect ? Icons.check : Icons.north_east;
    final barColor = perfect ? c.correct : c.brand;

    return Column(
      children: [
        // 결과 태그 pill
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 2, vertical: AppSpacing.xs + 2),
          decoration:
              BoxDecoration(color: tagBg, borderRadius: appPillRadius),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tagIcon, size: 13, color: tagFg),
              const SizedBox(width: AppSpacing.xs + 1),
              Text(tagText, style: AppText.label.copyWith(color: tagFg)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // 점수
        Text.rich(
          TextSpan(
            style: AppText.score.copyWith(color: c.textPrimary),
            children: [
              TextSpan(text: '$correct'),
              TextSpan(
                text: ' / $total',
                style: AppText.scoreUnit.copyWith(color: c.textTertiary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('정답률 $pct%',
            style: AppText.choice.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.md + 2),
        // 점수바
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: ClipRRect(
            borderRadius: appPillRadius,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : correct / total,
              minHeight: 8,
              color: barColor,
              backgroundColor: c.selTint,
            ),
          ),
        ),
      ],
    );
  }
}
