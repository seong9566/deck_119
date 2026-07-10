import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 결과 점수 뷰(UI_DESIGN_SYSTEM §5). 큰 `정답수 / 총` + 정답률 캡션.
class ScoreView extends StatelessWidget {
  final int correct;
  final int total;
  const ScoreView({super.key, required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$correct / $total',
            style: AppText.score.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text('정답률 $pct%',
            style: AppText.caption.copyWith(color: c.textSecondary)),
      ],
    );
  }
}
