import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 개수형 해설의 보기별 O/X 브레이크다운. 요약 줄(옳은 개수·기호) 아래에
/// 보기(ㄱ·ㄴ…)별 행을 두어 옳음/거짓과 거짓의 교정을 보여준다.
/// 보기 지문은 [stem]에서 파싱해 재사용한다(중복 저장 안 함).
class StatementBreakdown extends StatelessWidget {
  final List<StatementVerdict> breakdown;
  final String stem;

  const StatementBreakdown({
    super.key,
    required this.breakdown,
    required this.stem,
  });

  /// stem의 "ㄱ. 지문" 줄들을 {기호: 지문}으로 파싱.
  Map<String, String> _statements() {
    final map = <String, String>{};
    for (final line in stem.split('\n')) {
      final t = line.trimLeft();
      final dot = t.indexOf('.');
      if (dot >= 1 && dot <= 2) {
        map[t.substring(0, dot).trim()] = t.substring(dot + 1).trim();
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final texts = _statements();
    final okLabels = [for (final v in breakdown) if (v.correct) v.label];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 요약: 옳은 보기 N개 · ㄱ·ㄴ·ㄹ
        Row(
          children: [
            Text('옳은 보기',
                style: AppText.choice.copyWith(color: c.textPrimary, fontSize: 13)),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: c.onCorrect,
                border: Border.all(color: c.correct),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('${okLabels.length}개 · ${okLabels.join('·')}',
                  style: AppText.label
                      .copyWith(color: c.correctInk, letterSpacing: 0)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final v in breakdown) ...[
          _Row(verdict: v, text: texts[v.label] ?? ''),
          if (v != breakdown.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final StatementVerdict verdict;
  final String text;

  const _Row({required this.verdict, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ok = verdict.correct;
    final badgeBg = ok ? c.onCorrect : c.onWrong;
    final ink = ok ? c.correctInk : c.wrongInk;
    final border = ok ? c.correct : c.wrong;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: ok ? c.surfaceVariant : badgeBg,
        border: Border.all(color: border.withValues(alpha: ok ? 0.35 : 0.55)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 보기 기호 배지
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(verdict.label,
                style: AppText.label.copyWith(color: ink, letterSpacing: 0)),
          ),
          const SizedBox(width: AppSpacing.md - 2),
          // 지문 + (거짓이면) 교정
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: AppText.body.copyWith(
                        color: c.textPrimary, fontSize: 12.5, height: 1.5)),
                if (!ok && verdict.note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text('→ ${verdict.note}',
                      style: AppText.caption.copyWith(
                          color: c.wrongInk, height: 1.5, fontSize: 11.5)),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // O/X 판정
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(ok ? 'O' : 'X',
                style: AppText.label
                    .copyWith(color: ink, fontSize: 12, letterSpacing: 0)),
          ),
        ],
      ),
    );
  }
}
