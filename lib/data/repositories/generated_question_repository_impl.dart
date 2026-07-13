import '../../domain/entities/question.dart';
import '../../domain/repositories/generated_question_repository.dart';
import '../datasources/local/drift_generated_data_source.dart';

class GeneratedQuestionRepositoryImpl implements GeneratedQuestionRepository {
  final DriftGeneratedDataSource _ds;
  GeneratedQuestionRepositoryImpl(this._ds);

  @override
  Future<void> save(List<Question> questions) =>
      _ds.saveAll(questions, nowMs: DateTime.now().millisecondsSinceEpoch);

  @override
  Future<List<Question>> getAll(String subjectId) => _ds.getAll(subjectId);

  @override
  Stream<int> watchCount(String subjectId) => _ds.watchCount(subjectId);
}
