import '../../domain/entities/question.dart';
import '../../domain/repositories/ai_answer_repository.dart';
import '../datasources/local/drift_ai_answer_data_source.dart';

class AiAnswerRepositoryImpl implements AiAnswerRepository {
  final DriftAiAnswerDataSource _ds;
  AiAnswerRepositoryImpl(this._ds);

  @override
  Future<Map<String, int>> selections(String subjectId) =>
      _ds.selections(subjectId);

  @override
  Future<void> record(Question question, int selectedIndex) => _ds.record(
        question.id,
        subjectId: question.subjectId,
        selectedIndex: selectedIndex,
        isCorrect: question.isCorrect(selectedIndex),
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Future<void> clearSubject(String subjectId) => _ds.clearSubject(subjectId);

  @override
  Stream<int> watchUnsolvedCount(String subjectId) =>
      _ds.watchUnsolvedCount(subjectId);
}
