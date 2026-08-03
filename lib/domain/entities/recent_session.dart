import 'quiz_mode.dart';

/// 최근 이어풀기 세션(홈 대시보드용). 세션은 컬렉션 ⨯ 모드 단위로 저장된다.
class RecentSession {
  /// 세션 키 = 컬렉션 id(예: "fire-law::2026-3회").
  final String collectionId;

  /// 어떤 모드로 풀던 세션인가(카드 라벨·재진입 링크에 필요).
  final QuizMode mode;

  /// 마지막으로 머문 문항 인덱스(0-based).
  final int lastIndex;

  /// 세션의 출제 문항 수. 0 = 미상(v4 이전 세션) → 카테고리 전체 수를 쓴다.
  final int total;

  /// 갱신 시각(epoch ms).
  final int updatedAtMs;

  const RecentSession({
    required this.collectionId,
    required this.mode,
    required this.lastIndex,
    required this.total,
    required this.updatedAtMs,
  });
}
