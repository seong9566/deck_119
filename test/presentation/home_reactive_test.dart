import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// 반응형 회귀 방지 + 이어풀기 진입점(모드 라벨·AI 문제함) 검증.
void main() {
  final questions = [
    q('q1', 'Q1 지문', ['A1 옳음', 'A1 틀림']),
    q('q2', 'Q2 지문', ['A2 옳음', 'A2 틀림']),
    q('q3', 'Q3 지문', ['A3 옳음', 'A3 틀림']),
  ];

  Question aiQ(String id) => Question(
        id: id,
        subjectId: 'fire-law',
        type: QuestionType.mcq,
        year: null,
        stem: '$id 지문',
        choices: ['$id 옳음', '$id 틀림'],
        answerIndex: 0,
        explanation: '$id 해설',
        difficulty: 'v3',
        tags: const [],
        source: QuestionSource.ai,
      );

  Future<void> pumpHome(
    WidgetTester tester, {
    required FakeSessionRepository session,
    FakeGeneratedQuestionRepository? generated,
    FakeAiAnswerRepository? aiAnswers,
  }) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(session),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
          aiAnswerRepositoryProvider
              .overrideWithValue(aiAnswers ?? FakeAiAnswerRepository()),
          if (generated != null)
            generatedQuestionRepositoryProvider.overrideWithValue(generated),
        ],
        child: const Deck119App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('세션이 저장되면 홈 이어풀기가 재시작 없이 나타난다', (tester) async {
    final session = FakeSessionRepository();
    await pumpHome(tester, session: session);

    // 초기: 세션 없음 → 시작 유도, 이어풀기 없음.
    expect(find.text('학습을 시작해 보세요'), findsOneWidget);
    expect(find.textContaining('이어풀기 ·'), findsNothing);

    // 다른 경로에서 세션 생성('전체' 세트 id 's1')을 시뮬레이션.
    await session.save('s1', QuizMode.normal,
        lastIndex: 1, answers: [0, null], questionIds: const []);
    await tester.pumpAndSettle();

    // 재시작·위젯 재생성 없이 이어풀기가 반응형으로 나타난다(모드 라벨 포함).
    expect(find.text('이어풀기 · 전체 풀이'), findsOneWidget);
    expect(find.text('학습을 시작해 보세요'), findsNothing);
  });

  testWidgets('랜덤 세션이면 랜덤 라벨로 뜨고 저장된 순서 그대로 이어푼다', (tester) async {
    final session = FakeSessionRepository();
    await pumpHome(tester, session: session);

    // 랜덤으로 q3→q1→q2 순서를 풀다가 2번째에서 멈춘 상태.
    await session.save('s1', QuizMode.random,
        lastIndex: 1, answers: [0, null, null], questionIds: ['q3', 'q1', 'q2']);
    await tester.pumpAndSettle();

    expect(find.text('이어풀기 · 랜덤'), findsOneWidget);
    expect(find.text('2 / 3 문항'), findsOneWidget, reason: '세션 세트 크기가 분모');

    await tester.tap(find.text('이어풀기 · 랜덤'));
    await tester.pumpAndSettle();

    // 랜덤 모드로 진입해 저장된 순서의 2번째(q1)부터.
    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.textContaining('2 / 3'), findsOneWidget);
  });

  testWidgets('AI 문제함: 일부만 푼 상태면 이어풀기/처음부터를 묻는다', (tester) async {
    final session = FakeSessionRepository();
    final generated = FakeGeneratedQuestionRepository();
    final aiAnswers = FakeAiAnswerRepository();
    addTearDown(generated.dispose);
    addTearDown(aiAnswers.dispose);

    await generated.save([aiQ('ai-1'), aiQ('ai-2'), aiQ('ai-3')]);
    aiAnswers.bankSize = (_) => 3;
    await aiAnswers.record(aiQ('ai-1'), 0);

    await pumpHome(tester,
        session: session, generated: generated, aiAnswers: aiAnswers);

    expect(find.text('누적 3문항 · 미풀이 2문항'), findsOneWidget);

    await tester.tap(find.text('AI 문제함'));
    await tester.pumpAndSettle();

    expect(find.text('이어서 풀까요?'), findsOneWidget);
    expect(find.textContaining('3문항 중 1문항을 풀었어요'), findsOneWidget);

    await tester.tap(find.text('이어풀기'));
    await tester.pumpAndSettle();

    // 첫 미풀이(ai-2)부터 시작한다.
    expect(find.text('ai-2 지문'), findsOneWidget);
    expect(find.textContaining('2 / 3'), findsOneWidget);
  });

  testWidgets('AI 문제함: 처음부터 다시를 고르면 기록이 지워지고 1번부터', (tester) async {
    final session = FakeSessionRepository();
    final generated = FakeGeneratedQuestionRepository();
    final aiAnswers = FakeAiAnswerRepository();
    addTearDown(generated.dispose);
    addTearDown(aiAnswers.dispose);

    await generated.save([aiQ('ai-1'), aiQ('ai-2'), aiQ('ai-3')]);
    aiAnswers.bankSize = (_) => 3;
    await aiAnswers.record(aiQ('ai-1'), 0);

    await pumpHome(tester,
        session: session, generated: generated, aiAnswers: aiAnswers);

    await tester.tap(find.text('AI 문제함'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('처음부터 다시'));
    await tester.pumpAndSettle();

    expect(aiAnswers.answers, isEmpty, reason: '기록 전체 초기화');
    expect(find.text('ai-1 지문'), findsOneWidget);
    expect(find.textContaining('1 / 3'), findsOneWidget);
  });
}
