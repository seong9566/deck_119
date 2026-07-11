import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'type_badge.dart';

/// 문항 지문 블록(DESIGN_HANDOFF §2.2). 배지 + stem. 진행 위치는 ProgressHeader가
/// 소유하므로 여기선 유형 배지와 지문만. (콘텐츠에 별도 지문박스 데이터 없음 — 생략.)
class QuestionCard extends StatelessWidget {
  final QuestionType type;
  final String stem;

  const QuestionCard({
    super.key,
    required this.type,
    required this.stem,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeBadge(type: type),
        const SizedBox(height: AppSpacing.md + 2),
        Text(stem, style: AppText.stem.copyWith(color: c.textPrimary)),
      ],
    );
  }
}
