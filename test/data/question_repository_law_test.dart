import 'package:deck_119/data/content/law_category_catalog.dart';
import 'package:deck_119/data/datasources/content_data_source.dart';
import 'package:deck_119/data/repositories/question_repository_impl.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/domain/entities/subject.dart';
import 'package:flutter_test/flutter_test.dart';

/// 검수본 로드는 성공하지만 참고 세트 로드가 실패하는 데이터소스 더블.
class _AiRefFailsDataSource extends ContentDataSource {
  @override
  Future<ContentBundle> load() async => ContentBundle(
        subject: const Subject(id: 'fire-law', name: '소방관계법규'),
        questions: [
          const Question(
            id: 'base-1',
            subjectId: 'fire-law',
            type: QuestionType.mcq,
            year: 2025,
            stem: 's',
            choices: ['a', 'b'],
            answerIndex: 0,
            explanation: 'e',
            difficulty: 'v3',
            tags: ['소방기본법'],
          ),
        ],
      );

  @override
  Future<List<Question>> loadAiReference() async =>
      throw Exception('참고 세트 손상');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = QuestionRepositoryImpl(ContentDataSource());

  test('참고 세트 로드 실패해도 검수본만으로 동작한다(전파 안 함)', () async {
    final r = QuestionRepositoryImpl(_AiRefFailsDataSource());
    final qs = await r.getQuestions(kFireLawSubjectId);
    expect(qs, hasLength(1)); // base만 유지, 예외 전파 없음
    final cats = await r.getCategories();
    expect(cats.any((c) => c.id == catGibon), isTrue);
  });

  test('getCategories: 법령 6 + 기타 2 + 전체 1, 순서·count', () async {
    final cats = await repo.getCategories();
    final laws = cats.where((c) => c.group == '법령').toList();
    final etc = cats.where((c) => c.group == '기타').toList();
    final all = cats.where((c) => c.group == '전체').toList();

    expect(laws.map((c) => c.name).toList(),
        ['소방기본법', '화재예방법', '소방시설법', '소방공사업법', '위험물안전관리법', '화재조사법']);
    expect(etc.map((c) => c.name).toList(), ['교차법령', '심화 OX·계산']);
    expect(all.single.name, '전체');
    // 검수본 333 + 2026 실제 기출 25 = 358.
    expect(all.single.count, 358);

    final byId = {for (final c in cats) c.id: c.count};
    expect(byId[catGibon], 49); // 46 + 3
    expect(byId[catSisul], 77); // 71 + 6
    expect(byId[catCross], 42); // 39 + 3
    expect(byId[catSimhwaEtc], 18); // 참고 세트는 모두 법령 분류됨(변화 없음)
  });

  test('getQuestions(법령): 여러 연도(원형+심화) 병합', () async {
    final qs = await repo.getQuestions(catGibon);
    expect(qs.length, 49);
    // 원형(src:eduwill-mock 있음)과 심화(없음)가 함께 포함됨.
    expect(qs.any((q) => q.tags.contains('src:eduwill-mock')), isTrue);
    expect(qs.any((q) => !q.tags.contains('src:eduwill-mock')), isTrue);
  });

  test('getQuestions(전체): 과목 전체', () async {
    final qs = await repo.getQuestions(kFireLawSubjectId);
    expect(qs.length, 358);
  });
}
