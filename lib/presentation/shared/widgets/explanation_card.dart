import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'statement_breakdown.dart';

/// 해설 카드(DESIGN_HANDOFF §2.2). 정오답 배너(위)에 해설 카드(아래)가 붙은 형태.
/// 배너: tint 배경 + 아이콘 + 제목 / 카드: surface + "해설" 라벨 + 본문.
/// 개수형([breakdown] 있음)이면 본문을 보기별 O/X 브레이크다운으로 렌더한다.
class ExplanationCard extends StatelessWidget {
  final bool correct;
  final String explanation;

  /// 개수형 보기별 판정(비어 있으면 단일 텍스트 해설).
  final List<StatementVerdict> breakdown;

  /// breakdown 렌더 시 보기 지문 출처(문항 stem).
  final String stem;

  const ExplanationCard({
    super.key,
    required this.correct,
    required this.explanation,
    this.breakdown = const [],
    this.stem = '',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = correct ? c.onCorrect : c.onWrong;
    final border = correct ? c.correct : c.wrong;
    final ink = correct ? c.correctInk : c.wrongInk;
    const r = Radius.circular(AppSpacing.md + 2); // 14

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 배너(상단 라운드)
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: tint,
            border: Border.all(color: border, width: 1.5),
            borderRadius: const BorderRadius.only(topLeft: r, topRight: r),
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
        ),
        // 해설 카드(하단 라운드, 배너와 경계 공유)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(
              left: BorderSide(color: border, width: 1.5),
              right: BorderSide(color: border, width: 1.5),
              bottom: BorderSide(color: border, width: 1.5),
            ),
            borderRadius:
                const BorderRadius.only(bottomLeft: r, bottomRight: r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('해설', style: AppText.label.copyWith(color: c.textTertiary)),
              const SizedBox(height: AppSpacing.sm),
              if (breakdown.isNotEmpty)
                StatementBreakdown(breakdown: breakdown, stem: stem)
              else
                Text(explanation,
                    style: AppText.body.copyWith(color: c.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
