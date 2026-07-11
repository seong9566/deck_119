/// 이어풀기 세션(쓰기) 포트. normal 모드 한정, 과목별 마지막 위치.
/// 구현은 data 레이어(Isar SessionState).
abstract interface class SessionRepository {
  /// 저장된 세션(마지막 위치 + 문항별 선택, null = 미응답). 없으면 null.
  Future<({int lastIndex, List<int?> answers})?> load(String subjectId);

  /// 세션 저장(upsert) — 마지막 위치와 문항별 선택(null = 미응답).
  Future<void> save(String subjectId, int lastIndex, List<int?> answers);

  /// 세션 삭제(finish 시).
  Future<void> clear(String subjectId);
}
