import '../../domain/entities/question.dart';
import '../../domain/entities/question_category.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/question_repository.dart';
import '../content/law_category_catalog.dart';
import '../datasources/content_data_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final ContentDataSource _content;
  ContentBundle? _cache;

  QuestionRepositoryImpl(this._content);

  /// 검수본(fire-law.json)에 2026 실제 기출(fire-law-2026-ai.json)을 합친 문제풀.
  /// 후자는 지문·정답이 실제 기출이라 법령 카테고리에 함께 녹여 채점·통계 대상에 포함한다.
  Future<ContentBundle> _bundle() async {
    if (_cache != null) return _cache!;
    final base = await _content.load();
    final aiRef = await _content.loadAiReference();
    return _cache = ContentBundle(
      subject: base.subject,
      questions: [...base.questions, ...aiRef],
    );
  }

  @override
  Future<List<Subject>> getSubjects() async => [(await _bundle()).subject];

  @override
  Future<List<Question>> getQuestions(String categoryId) async {
    final qs = (await _bundle()).questions;
    if (categoryId == kFireLawSubjectId) return qs.toList(); // 전체
    return qs.where((q) => classifyCategoryId(q) == categoryId).toList();
  }

  @override
  Future<List<QuestionCategory>> getCategories() async {
    final qs = (await _bundle()).questions.toList();
    final counts = <String, int>{};
    for (final q in qs) {
      counts.update(classifyCategoryId(q), (v) => v + 1, ifAbsent: () => 1);
    }
    final result = <QuestionCategory>[
      for (final def in lawCategories)
        if ((counts[def.id] ?? 0) > 0)
          QuestionCategory(
              id: def.id,
              name: def.name,
              description: def.description,
              group: def.group,
              count: counts[def.id]!),
      QuestionCategory(
          id: allCategory.id,
          name: allCategory.name,
          group: allCategory.group,
          count: qs.length),
    ];
    return result;
  }
}
