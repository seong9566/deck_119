import 'package:deck_119/di.dart';
import 'package:deck_119/domain/repositories/ai_question_repository.dart';
import 'package:deck_119/presentation/ai_gen/viewmodel/ai_generation_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeAiQuestionRepository aiRepository;
  late FakeNotificationService notificationService;
  late FakeGeneratedQuestionRepository generatedRepository;
  late ProviderContainer container;

  setUp(() {
    aiRepository = FakeAiQuestionRepository();
    notificationService = FakeNotificationService();
    generatedRepository = FakeGeneratedQuestionRepository();
    container = ProviderContainer(
      overrides: [
        aiQuestionRepositoryProvider.overrideWithValue(aiRepository),
        notificationServiceProvider.overrideWithValue(notificationService),
        generatedQuestionRepositoryProvider
            .overrideWithValue(generatedRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    aiRepository.dispose();
    generatedRepository.dispose();
  });

  test('start가 생성 요청을 제출하고 활성 작업을 노출한다', () async {
    final controller = container.read(aiGenerationControllerProvider.notifier);

    final started = await controller.start(
      subjectId: 'fire-law',
      options: (yearScope: 'all', count: 10, type: 'mcq'),
    );

    expect(started, isTrue);
    expect(aiRepository.submitCalls, hasLength(1));
    expect(aiRepository.submitCalls.single.subjectId, 'fire-law');
    expect(container.read(aiGenerationControllerProvider)?.docId, 'doc-1');
  });

  test('진행 중인 작업이 있으면 추가 생성을 차단한다', () async {
    final controller = container.read(aiGenerationControllerProvider.notifier);
    final options = (yearScope: 'all', count: 10, type: 'mcq');
    await controller.start(subjectId: 'fire-law', options: options);

    final started = await controller.start(
      subjectId: 'fire-law',
      options: options,
    );

    expect(started, isFalse);
    expect(aiRepository.submitCalls, hasLength(1));
  });

  test('완료 결과를 저장하고 완료 알림 후 작업을 정리한다', () async {
    final controller = container.read(aiGenerationControllerProvider.notifier);
    await controller.start(
      subjectId: 'fire-law',
      options: (yearScope: '2026', count: 10, type: 'mixed'),
    );
    final questions = [
      q('q1', 'Q1 지문', ['A', 'B']),
      q('q2', 'Q2 지문', ['A', 'B']),
    ];

    aiRepository.emit(AiGenDone(questions));
    await _flushListeners();

    expect(generatedRepository.savedQuestions, questions);
    expect(notificationService.doneCounts, [2]);
    expect(notificationService.errorCount, 0);
    expect(aiRepository.removePendingCalls, ['doc-1']);
    expect(container.read(aiGenerationControllerProvider), isNull);
  });

  test('실패 결과는 오류 알림 후 저장 없이 작업을 정리한다', () async {
    final controller = container.read(aiGenerationControllerProvider.notifier);
    await controller.start(
      subjectId: 'fire-law',
      options: (yearScope: 'all', count: 10, type: 'ox'),
    );

    aiRepository.emit(const AiGenError('생성 실패'));
    await _flushListeners();

    expect(generatedRepository.savedQuestions, isEmpty);
    expect(notificationService.doneCounts, isEmpty);
    expect(notificationService.errorCount, 1);
    expect(aiRepository.removePendingCalls, ['doc-1']);
    expect(container.read(aiGenerationControllerProvider), isNull);
  });

  test('submit 대기 중 재요청도 중복 제출 없이 차단한다', () async {
    final controller = container.read(aiGenerationControllerProvider.notifier);
    final options = (yearScope: 'all', count: 10, type: 'mcq');

    // 첫 start의 submit await 중 두 번째 start를 발사(둘 다 await 없이).
    final first = controller.start(subjectId: 'fire-law', options: options);
    final second = controller.start(subjectId: 'fire-law', options: options);
    final results = await Future.wait([first, second]);

    expect(results, [true, false]);
    expect(aiRepository.submitCalls, hasLength(1));
  });

  test('watch 스트림 에러 시 오류 알림 후 작업을 정리한다', () async {
    final controller = container.read(aiGenerationControllerProvider.notifier);
    await controller.start(
      subjectId: 'fire-law',
      options: (yearScope: 'all', count: 10, type: 'mcq'),
    );

    aiRepository.emitError(Exception('firestore 권한 거부'));
    await _flushListeners();

    expect(notificationService.errorCount, 1);
    expect(generatedRepository.savedQuestions, isEmpty);
    expect(aiRepository.removePendingCalls, ['doc-1']);
    expect(container.read(aiGenerationControllerProvider), isNull);
  });
}

Future<void> _flushListeners() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
