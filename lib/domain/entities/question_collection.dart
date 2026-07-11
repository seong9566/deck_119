/// 문제 세트(컬렉션). 원형 회차별·심화·전체를 하나의 선택 단위로 표현한다.
/// id는 풀이·세션·통계에 그대로 쓰이는 필터 키(예: "fire-law::2026-1회", "fire-law::심화", "fire-law").
class QuestionCollection {
  final String id;

  /// 표시명(예: "2026 1회", "심화 문제", "전체").
  final String name;

  /// 묶음 구분(원형 · 심화 · 전체) — 목록 섹션 헤더용.
  final String group;

  final int count;

  const QuestionCollection({
    required this.id,
    required this.name,
    required this.group,
    required this.count,
  });
}
