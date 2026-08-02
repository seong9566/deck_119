import '../entities/resume_info.dart';
import '../repositories/question_repository.dart';
import '../repositories/session_repository.dart';

/// 이어풀기 정보 조회 — 해당 카테고리에서 가장 최근에 풀던 세션(모드 무관).
/// 아무 응답도 없거나 이미 끝까지 간 세션이면 이어풀기가 무의미하므로 null.
class GetResumeInfo {
  final QuestionRepository _questions;
  final SessionRepository _session;

  GetResumeInfo(this._questions, this._session);

  Future<ResumeInfo?> call(String categoryId) async {
    final recent =
        await _session.recentSessions(limit: 1, categoryId: categoryId);
    if (recent.isEmpty) return null;

    final mode = recent.first.mode;
    final snap = await _session.load(categoryId, mode);
    if (snap == null) return null;

    // 출제 목록이 있으면 그 길이가 총 문항수(랜덤·오답 세트는 저장소 전체가 아니다).
    final total = snap.questionIds.isNotEmpty
        ? snap.questionIds.length
        : (await _questions.getQuestions(categoryId)).length;
    if (total == 0 || snap.lastIndex >= total) return null;

    // 첫 문항만 풀고 나가도(lastIndex 0) 이어풀기가 떠야 한다.
    final hasAnswer = snap.answers.any((a) => a != null);
    if (!hasAnswer && snap.lastIndex <= 0) return null;

    return ResumeInfo(
      mode: mode,
      lastIndex: snap.lastIndex,
      total: total,
      answers: snap.answers,
    );
  }
}
