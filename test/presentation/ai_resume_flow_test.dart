import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/ai_quiz_set.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/presentation/ai_gen/viewmodel/ai_gen_view_model.dart';
import 'package:deck_119/presentation/quiz/view/quiz_page.dart';
import 'package:deck_119/presentation/quiz/viewmodel/quiz_view_model.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// 문제 1 회귀 방지: AI 문제를 새로 발급해도 이미 푼 문항의 답이 남아야 하고,
/// 재진입 시 처음이 아니라 첫 미풀이 문항부터 이어풀어야 한다.
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

void main() {
  late FakeGeneratedQuestionRepository generated;
  late FakeAiAnswerRepository aiAnswers;
  late FakeProgressRepository progress;
  late ProviderContainer container;

  setUp(() {
    generated = FakeGeneratedQuestionRepository();
    aiAnswers = FakeAiAnswerRepository();
    progress = FakeProgressRepository();
    container = ProviderContainer(overrides: [
      generatedQuestionRepositoryProvider.overrideWithValue(generated),
      aiAnswerRepositoryProvider.overrideWithValue(aiAnswers),
      progressRepositoryProvider.overrideWithValue(progress),
      questionRepositoryProvider
          .overrideWithValue(const FakeQuestionRepository([])),
    ]);
  });
  tearDown(() {
    container.dispose();
    generated.dispose();
    aiAnswers.dispose();
  });

  const QuizArgs args =
      (categoryId: 'fire-law', mode: QuizMode.ai, resume: false);

  /// 홈에서 세트를 구성해 핸드오프한 뒤 ai 모드 풀이 화면을 띄운다.
  /// 진입할 때마다 풀이 상태를 새로 만든다(실제 앱에선 화면을 나가면 autoDispose).
  Future<AiQuizSet> pumpAiQuiz(WidgetTester tester) async {
    container.invalidate(quizViewModelProvider(args));
    final set = await container.read(getAiQuizSetProvider)('fire-law');
    container.read(aiQuizSetProvider.notifier).state = set;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const QuizPage(categoryId: 'fire-law', mode: QuizMode.ai),
      ),
    ));
    await tester.pumpAndSettle();
    return set;
  }

  testWidgets('푼 문항의 답은 새 문제를 발급해도 남고, 첫 미풀이부터 이어푼다', (tester) async {
    await generated.save([for (var i = 1; i <= 3; i++) aiQ('ai-$i')]);

    // 1차: 처음부터 시작해 2문항을 푼다.
    await pumpAiQuiz(tester);
    expect(find.text('ai-1 지문'), findsOneWidget);
    expect(find.textContaining('1 / 3'), findsOneWidget);

    await tester.tap(find.text('ai-1 옳음')); // 정답
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ai-2 틀림')); // 오답
    await tester.pumpAndSettle();

    // 여기서 이탈 — 화면을 떠나면 풀이 상태(autoDispose)는 파기된다.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    // 응답은 AI 전용 기록에 남아 있다.
    expect(aiAnswers.answers, {'ai-1': 0, 'ai-2': 1});
    // 참고용이라 통계·오답노트는 오염시키지 않는다.
    expect(progress.wrong, isEmpty);

    // 2차: AI 문제를 새로 2문항 발급(뒤에 누적).
    await generated.save([aiQ('ai-4'), aiQ('ai-5')]);

    final set = await pumpAiQuiz(tester);
    expect(set.total, 5);
    expect(set.solvedCount, 2, reason: '이전에 푼 2문항은 그대로 풀린 상태');
    expect(set.answers, [0, 1, null, null, null]);

    // 3번(첫 미풀이)부터 시작한다.
    expect(find.text('ai-3 지문'), findsOneWidget);
    expect(find.textContaining('3 / 5'), findsOneWidget);

    // 뒤로 가면 이전에 고른 답과 해설이 복원돼 있다.
    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();
    expect(find.text('ai-2 지문'), findsOneWidget);
    expect(find.text('ai-2 해설'), findsOneWidget);
  });

  testWidgets('처음부터 다시: 기록을 초기화하면 1번부터 미풀이 상태로 시작한다', (tester) async {
    await generated.save([for (var i = 1; i <= 3; i++) aiQ('ai-$i')]);
    await aiAnswers.record(aiQ('ai-1'), 0);
    await aiAnswers.record(aiQ('ai-2'), 1);

    await container.read(resetAiAnswersProvider)('fire-law');
    final set = await pumpAiQuiz(tester);

    expect(set.solvedCount, 0);
    expect(find.text('ai-1 지문'), findsOneWidget);
    expect(find.textContaining('1 / 3'), findsOneWidget);
    expect(find.text('ai-1 해설'), findsNothing, reason: '미풀이라 해설이 없다');
  });

  testWidgets('ai 결과 화면에는 다시 풀기가 없다(시작 방식은 홈에서 정한다)', (tester) async {
    await generated.save([aiQ('ai-1')]);
    await pumpAiQuiz(tester);

    await tester.tap(find.text('ai-1 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(find.text('홈으로'), findsOneWidget);
    expect(find.text('다시 풀기'), findsNothing);
  });

  test('AiQuizSet: 전부 풀었으면 첫 문항으로, 일부만 풀었으면 물어봐야 한다', () {
    final three = [aiQ('ai-1'), aiQ('ai-2'), aiQ('ai-3')];

    final solved =
        AiQuizSet(questions: three, answers: const [0, 1, 0]);
    expect(solved.firstUnsolvedIndex, 0, reason: '다 풀었으면 처음부터 보여준다');
    expect(solved.isPartiallySolved, isFalse);
    expect(solved.unsolvedCount, 0);

    final partial =
        AiQuizSet(questions: three, answers: const [0, null, 1]);
    expect(partial.firstUnsolvedIndex, 1);
    expect(partial.isPartiallySolved, isTrue);
    expect(partial.reset.answers, [null, null, null]);
  });
}
