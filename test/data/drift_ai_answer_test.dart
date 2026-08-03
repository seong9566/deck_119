import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:deck_119/data/datasources/local/drift_ai_answer_data_source.dart';
import 'package:deck_119/data/datasources/local/drift_generated_data_source.dart';
import 'package:deck_119/data/repositories/ai_answer_repository_impl.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Question _q(String id, {String subjectId = 'fire-law'}) => Question(
      id: id,
      subjectId: subjectId,
      type: QuestionType.mcq,
      year: null,
      stem: '$id 지문',
      choices: const ['①', '②'],
      answerIndex: 0,
      explanation: '$id 해설',
      difficulty: 'v3',
      tags: const [],
      source: QuestionSource.ai,
    );

void main() {
  late AppDatabase db;
  late DriftGeneratedDataSource generated;
  late AiAnswerRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    generated = DriftGeneratedDataSource(db);
    repo = AiAnswerRepositoryImpl(DriftAiAnswerDataSource(db));
  });
  tearDown(() async => db.close());

  test('응답 기록이 저장·갱신되고 과목별로 조회된다', () async {
    await repo.record(_q('ai-1'), 0); // 정답
    await repo.record(_q('ai-2'), 1); // 오답
    await repo.record(_q('other', subjectId: 's2'), 1);

    expect(await repo.selections('fire-law'), {'ai-1': 0, 'ai-2': 1});

    // 같은 문항 재응답은 덮어쓴다.
    await repo.record(_q('ai-2'), 0);
    expect(await repo.selections('fire-law'), {'ai-1': 0, 'ai-2': 0});
  });

  test('과목 기록 초기화는 해당 과목만 지운다', () async {
    await repo.record(_q('ai-1'), 0);
    await repo.record(_q('other', subjectId: 's2'), 0);

    await repo.clearSubject('fire-law');
    expect(await repo.selections('fire-law'), isEmpty);
    expect(await repo.selections('s2'), {'other': 0});
  });

  test('적립함은 생성순(오래된 것이 앞)으로 나온다', () async {
    await generated.saveAll([_q('ai-1'), _q('ai-2')], nowMs: 100);
    await generated.saveAll([_q('ai-3')], nowMs: 200); // 나중 배치

    final all = await generated.getAll('fire-law');
    expect(all.map((q) => q.id).toList(), ['ai-1', 'ai-2', 'ai-3'],
        reason: '새로 만든 문항이 뒤에 쌓여야 이어풀기 위치가 밀리지 않는다');
  });

  test('watchUnsolvedCount: 적립·응답에 따라 미풀이 수가 갱신된다', () async {
    await generated.saveAll([_q('ai-1'), _q('ai-2'), _q('ai-3')], nowMs: 100);

    final done = expectLater(
      repo.watchUnsolvedCount('fire-law'),
      emitsThrough(1), // 3문항 중 2문항 응답 → 1
    );
    await repo.record(_q('ai-1'), 0);
    await repo.record(_q('ai-2'), 1);
    await done;
  });
}
