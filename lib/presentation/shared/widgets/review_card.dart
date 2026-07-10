import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'explanation_card.dart';

/// 결과 오답 리뷰 카드(UI_DESIGN_SYSTEM §6). 문항·내 답(✕)·정답(✓)·해설.
class ReviewCard extends StatelessWidget {
  final int order;
  final String stem;
  final String myAnswer;
  final String correctAnswer;
  final String explanation;

  const ReviewCard({
    super.key,
    required this.order,
    required this.stem,
    required this.myAnswer,
    required this.correctAnswer,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appMdRadius,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$order번', style: AppText.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(stem, style: AppText.stem.copyWith(color: c.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          _AnswerRow(
              icon: Icons.close, color: c.wrong, label: '내 답', value: myAnswer),
          const SizedBox(height: AppSpacing.xs),
          _AnswerRow(
              icon: Icons.check,
              color: c.correct,
              label: '정답',
              value: correctAnswer),
          const SizedBox(height: AppSpacing.md),
          ExplanationCard(explanation: explanation),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _AnswerRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text('$label  ', style: AppText.label.copyWith(color: c.textSecondary)),
        Expanded(
          child: Text(value, style: AppText.body.copyWith(color: c.textPrimary)),
        ),
      ],
    );
  }
}
