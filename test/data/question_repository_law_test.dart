import 'package:deck_119/data/content/law_category_catalog.dart';
import 'package:deck_119/data/datasources/content_data_source.dart';
import 'package:deck_119/data/repositories/question_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = QuestionRepositoryImpl(ContentDataSource());

  test('getCategories: 법령 6 + 기타 2 + 전체 1, 순서·count', () async {
    final cats = await repo.getCategories();
    final laws = cats.where((c) => c.group == '법령').toList();
    final etc = cats.where((c) => c.group == '기타').toList();
    final all = cats.where((c) => c.group == '전체').toList();

    expect(laws.map((c) => c.name).toList(),
        ['소방기본법', '화재예방법', '소방시설법', '소방공사업법', '위험물안전관리법', '화재조사법']);
    expect(etc.map((c) => c.name).toList(), ['교차법령', '심화 OX·계산']);
    expect(all.single.name, '전체');
    expect(all.single.count, 333);

    final byId = {for (final c in cats) c.id: c.count};
    expect(byId[catGibon], 46);
    expect(byId[catSisul], 71);
    expect(byId[catCross], 39);
    expect(byId[catSimhwaEtc], 18);
  });

  test('getQuestions(법령): 여러 연도(원형+심화) 병합', () async {
    final qs = await repo.getQuestions(catGibon);
    expect(qs.length, 46);
    // 원형(src:eduwill-mock 있음)과 심화(없음)가 함께 포함됨.
    expect(qs.any((q) => q.tags.contains('src:eduwill-mock')), isTrue);
    expect(qs.any((q) => !q.tags.contains('src:eduwill-mock')), isTrue);
  });

  test('getQuestions(전체): 과목 전체', () async {
    final qs = await repo.getQuestions(kFireLawSubjectId);
    expect(qs.length, 333);
  });
}
