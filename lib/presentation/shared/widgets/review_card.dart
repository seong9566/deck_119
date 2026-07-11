import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 결과 오답 리뷰 카드(DESIGN_HANDOFF §2.2). 번호칩 + 지문 / 내 답(✕)·정답(✓) 칩 /
/// 점선 위 해설.
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
        borderRadius: appCardRadius,
        border: Border.all(color: c.outline),
        boxShadow: appCardShadow(c),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 칩
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.selTint,
                  borderRadius: appSmRadius,
                ),
                child: Text('$order',
                    style: AppText.label.copyWith(color: c.textSecondary)),
              ),
              const SizedBox(width: AppSpacing.md - 2),
              Expanded(
                child: Text(stem,
                    style: AppText.choice.copyWith(
                        color: c.textPrimary, height: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _AnswerChip(
                text: '✕ 내 답  $myAnswer',
                bg: c.onWrong,
                border: c.wrong,
                fg: c.wrongInk,
              ),
              _AnswerChip(
                text: '✓ 정답  $correctAnswer',
                bg: c.onCorrect,
                border: c.correct,
                fg: c.correctInk,
              ),
            ],
          ),
          // 점선 위 해설
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: _DashedLine(color: c.outline),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(explanation,
              style: AppText.caption.copyWith(
                  color: c.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}

/// 해설 위 점선 구분선(목업 border-top:1px dashed).
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedPainter(color)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  _DashedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0, gap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) => old.color != color;
}

class _AnswerChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color border;
  final Color fg;
  const _AnswerChip({
    required this.text,
    required this.bg,
    required this.border,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - 2, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
