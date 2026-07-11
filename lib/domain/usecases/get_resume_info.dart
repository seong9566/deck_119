import '../entities/resume_info.dart';
import '../repositories/question_repository.dart';
import '../repositories/session_repository.dart';

/// 이어풀기 정보 조회. 세션이 처음(0)·끝(>=total)이면 이어풀기 무의미 → null.
class GetResumeInfo {
  final QuestionRepository _questions;
  final SessionRepository _session;

  GetResumeInfo(this._questions, this._session);

  Future<ResumeInfo?> call(String subjectId) async {
    final snap = await _session.load(subjectId);
    if (snap == null || snap.lastIndex <= 0) return null;
    final total = (await _questions.getQuestions(subjectId)).length;
    if (snap.lastIndex >= total) return null;
    return ResumeInfo(
      lastIndex: snap.lastIndex,
      total: total,
      answers: snap.answers,
    );
  }
}
