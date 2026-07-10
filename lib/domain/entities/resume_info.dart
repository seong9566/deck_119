/// 이어풀기 정보(normal 모드). 마지막 위치와 총 문항수.
class ResumeInfo {
  /// 마지막으로 머문 문항 인덱스(0-based).
  final int lastIndex;
  final int total;

  const ResumeInfo({required this.lastIndex, required this.total});

  /// 사람이 읽는 위치(1-based).
  int get position => lastIndex + 1;
}
