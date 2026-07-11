import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:deck_119/presentation/shared/widgets/explanation_card.dart';
import 'package:deck_119/presentation/shared/widgets/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 개수형 해설이 보기별 O/X 브레이크다운으로 렌더되는지 검증.
void main() {
  const stem = '다음 <보기> 중 옳은 것은 모두 몇 개인가?\n'
      'ㄱ. 소방용수시설 조사결과는 2년간 보관한다.\n'
      'ㄴ. 이동탱크저장소는 정기점검 대상이지만 예방규정 작성 대상은 아니다.\n'
      'ㄷ. 소방안전관리 전담 대상은 특급·1급·2급 대상물이다.\n'
      'ㄹ. 강화 시 소화기구·비상경보설비·자동화재탐지설비는 강화 기준을 적용할 수 있다.\n'
      'ㅁ. 화재조사관은 3명 이상 배치해야 한다.';

  const breakdown = [
    StatementVerdict(label: 'ㄱ', correct: true),
    StatementVerdict(label: 'ㄴ', correct: true),
    StatementVerdict(label: 'ㄷ', correct: false, note: '전담 대상은 특급·1급만(2급 제외)'),
    StatementVerdict(label: 'ㄹ', correct: true),
    StatementVerdict(label: 'ㅁ', correct: false, note: '화재조사관은 2명 이상'),
  ];

  Widget host(Widget child) =>
      MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));

  testWidgets('개수형: 보기별 O/X·교정이 렌더되고 단일 문단 해설은 안 보인다', (tester) async {
    await tester.pumpWidget(host(const ExplanationCard(
      correct: false,
      explanation: '옳은 것은 ㄱ·ㄴ·ㄹ (3개). ㄷ 거짓 — …. ㅁ 거짓 — ….',
      breakdown: breakdown,
      stem: stem,
    )));
    await tester.pumpAndSettle();

    // 요약(옳은 개수·기호)
    expect(find.text('옳은 보기'), findsOneWidget);
    expect(find.text('3개 · ㄱ·ㄴ·ㄹ'), findsOneWidget);

    // stem에서 파싱한 보기 지문이 각 행에 노출
    expect(find.text('소방용수시설 조사결과는 2년간 보관한다.'), findsOneWidget);
    // 거짓 보기의 교정
    expect(find.text('→ 전담 대상은 특급·1급만(2급 제외)'), findsOneWidget);
    expect(find.text('→ 화재조사관은 2명 이상'), findsOneWidget);
    // O/X 판정 배지(옳음 3·거짓 2)
    expect(find.text('O'), findsNWidgets(3));
    expect(find.text('X'), findsNWidgets(2));

    // 브레이크다운이 있으면 단일 문단 해설 원문은 렌더하지 않는다
    expect(find.textContaining('옳은 것은 ㄱ·ㄴ·ㄹ (3개)'), findsNothing);
  });

  testWidgets('일반 문항: breakdown 없으면 기존 단일 텍스트 해설', (tester) async {
    await tester.pumpWidget(host(const ExplanationCard(
      correct: true,
      explanation: '정답 근거 해설 본문.',
    )));
    await tester.pumpAndSettle();

    expect(find.text('정답 근거 해설 본문.'), findsOneWidget);
    expect(find.text('옳은 보기'), findsNothing);
  });

  testWidgets('시험 결과 ReviewCard도 개수형이면 보기별 O/X로 렌더', (tester) async {
    await tester.pumpWidget(host(const SingleChildScrollView(
      child: ReviewCard(
        order: 3,
        stem: stem,
        myAnswer: '1개',
        correctAnswer: '3개',
        explanation: '옳은 것은 ㄱ·ㄴ·ㄹ (3개). …',
        breakdown: breakdown,
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.text('옳은 보기'), findsOneWidget);
    expect(find.text('3개 · ㄱ·ㄴ·ㄹ'), findsOneWidget);
    expect(find.text('→ 화재조사관은 2명 이상'), findsOneWidget);
    // breakdown이 단일 텍스트 해설을 대체
    expect(find.textContaining('옳은 것은 ㄱ·ㄴ·ㄹ (3개)'), findsNothing);
  });
}
