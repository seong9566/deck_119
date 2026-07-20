/// 문제 카테고리(법령·교차·심화·전체). id는 풀이·세션·통계에 쓰이는 필터 키.
class QuestionCategory {
  final String id;
  final String name;

  /// 묶음 구분('법령'·'기타'·'전체') — 목록 섹션 헤더용.
  final String group;
  final int count;

  const QuestionCategory({
    required this.id,
    required this.name,
    required this.group,
    required this.count,
  });
}
