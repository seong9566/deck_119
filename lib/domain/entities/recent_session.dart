/// 최근 이어풀기 세션(홈 대시보드용). 세션은 컬렉션 id 단위로 저장된다.
class RecentSession {
  /// 세션 키 = 컬렉션 id(예: "fire-law::2026-3회").
  final String collectionId;

  /// 마지막으로 머문 문항 인덱스(0-based).
  final int lastIndex;

  /// 갱신 시각(epoch ms).
  final int updatedAtMs;

  const RecentSession({
    required this.collectionId,
    required this.lastIndex,
    required this.updatedAtMs,
  });
}
