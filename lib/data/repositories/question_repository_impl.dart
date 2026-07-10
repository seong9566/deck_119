import '../../domain/entities/question.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/content_data_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final ContentDataSource _content;
  ContentBundle? _cache;

  QuestionRepositoryImpl(this._content);

  Future<ContentBundle> _bundle() async => _cache ??= await _content.load();

  @override
  Future<List<Subject>> getSubjects() async => [(await _bundle()).subject];

  @override
  Future<List<Question>> getQuestions(String subjectId) async {
    final bundle = await _bundle();
    return bundle.questions.where((q) => q.subjectId == subjectId).toList();
  }
}
