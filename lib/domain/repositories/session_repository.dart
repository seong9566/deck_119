/// 이어풀기 세션(쓰기) 포트. normal 모드 한정, 과목별 마지막 위치.
/// 구현은 data 레이어(Isar SessionState).
abstract interface class SessionRepository {
  /// 과목의 마지막 위치(0-based). 없으면 null.
  Future<int?> getLastIndex(String subjectId);

  /// 마지막 위치 저장(upsert).
  Future<void> save(String subjectId, int lastIndex);

  /// 세션 삭제(finish 시).
  Future<void> clear(String subjectId);
}
