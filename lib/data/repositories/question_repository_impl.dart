import '../../domain/entities/question.dart';
import '../../domain/entities/question_collection.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/content_data_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final ContentDataSource _content;
  ContentBundle? _cache;

  QuestionRepositoryImpl(this._content);

  Future<ContentBundle> _bundle() async => _cache ??= await _content.load();

  static const _sep = '::';

  /// 원형 회차 태그(예: "2026-1회").
  static final _roundTag = RegExp(r'^(\d{4})-(\d+)회$');

  /// 원형(동형모의고사) 표식 태그. 심화 세트는 이 태그가 없는 문항.
  static const _srcTag = 'src:eduwill-mock';

  @override
  Future<List<Subject>> getSubjects() async => [(await _bundle()).subject];

  @override
  Future<List<Question>> getQuestions(String collectionId) async {
    final bundle = await _bundle();
    final i = collectionId.indexOf(_sep);
    final subjectId = i < 0 ? collectionId : collectionId.substring(0, i);
    final filter = i < 0 ? null : collectionId.substring(i + _sep.length);

    final base = bundle.questions.where((q) => q.subjectId == subjectId);
    if (filter == null) return base.toList();
    if (filter == '심화') {
      return base.where((q) => !q.tags.contains(_srcTag)).toList();
    }
    // 회차 태그 등 일반 태그 필터.
    return base.where((q) => q.tags.contains(filter)).toList();
  }

  @override
  Future<List<QuestionCollection>> getCollections() async {
    final bundle = await _bundle();
    final subj = bundle.subject.id;
    final qs = bundle.questions.where((q) => q.subjectId == subj).toList();

    // 원형: 회차 태그 수집·정렬(연도→회차).
    final rounds = <String>{};
    for (final q in qs) {
      for (final t in q.tags) {
        if (_roundTag.hasMatch(t)) rounds.add(t);
      }
    }
    final sorted = rounds.toList()
      ..sort((a, b) {
        final ma = _roundTag.firstMatch(a)!, mb = _roundTag.firstMatch(b)!;
        final ya = int.parse(ma[1]!), yb = int.parse(mb[1]!);
        return ya != yb
            ? ya.compareTo(yb)
            : int.parse(ma[2]!).compareTo(int.parse(mb[2]!));
      });

    final result = <QuestionCollection>[];
    for (final t in sorted) {
      final m = _roundTag.firstMatch(t)!;
      result.add(QuestionCollection(
        id: '$subj$_sep$t',
        name: '${m[1]} ${m[2]}회',
        group: '원형',
        count: qs.where((q) => q.tags.contains(t)).length,
      ));
    }
    result.add(QuestionCollection(
      id: '$subj$_sep심화',
      name: '심화 문제',
      group: '심화',
      count: qs.where((q) => !q.tags.contains(_srcTag)).length,
    ));
    result.add(QuestionCollection(
      id: subj,
      name: '전체',
      group: '전체',
      count: qs.length,
    ));
    return result;
  }
}
