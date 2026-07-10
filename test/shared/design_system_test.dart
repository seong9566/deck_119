import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/presentation/shared/theme/app_colors.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:deck_119/presentation/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 디자인 시스템 파운데이션(T9): 핵심 컴포넌트가 라이트/다크 양쪽에서
/// AppColors 토큰을 해석하며 예외 없이 렌더되는지 확인.
void main() {
  Widget host(ThemeData theme, Widget child) => MaterialApp(
        theme: theme,
        home: Scaffold(body: child),
      );

  final sample = Column(
    children: [
      const QuestionCard(
        position: 1,
        total: 25,
        type: QuestionType.mcq,
        stem: '지문 샘플',
      ),
      const ChoiceTile(label: '선택지', status: ChoiceStatus.correct),
      const AnswerBanner(correct: false),
      const ExplanationCard(explanation: '해설 본문'),
      const ProgressHeader(position: 3, total: 25, value: 0.12),
      const ScoreView(correct: 20, total: 25),
      const ModeTile(icon: Icons.list_alt, label: '전체', description: '설명'),
      const ReviewCard(
        order: 2,
        stem: '리뷰 지문',
        myAnswer: '내가 고른 답',
        correctAnswer: '진짜 정답',
        explanation: '리뷰 해설',
      ),
      const EmptyState(icon: Icons.inbox, message: '비었어요'),
      ThemeRadioGroup(value: ThemeMode.system, onChanged: (_) {}),
    ],
  );

  for (final (name, theme) in [
    ('라이트', AppTheme.light()),
    ('다크', AppTheme.dark()),
  ]) {
    testWidgets('$name 테마에서 공용 컴포넌트가 렌더된다', (tester) async {
      await tester.pumpWidget(host(theme, SingleChildScrollView(child: sample)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(theme.extension<AppColors>(), isNotNull);
      expect(find.text('지문 샘플'), findsOneWidget);
      expect(find.text('오답입니다'), findsOneWidget);
    });
  }
}
