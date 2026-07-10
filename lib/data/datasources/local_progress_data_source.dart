/// 로컬 진척·오답 저장소.
///
/// TODO(Isar): 현재는 인메모리 — 앱 재시작 시 초기화된다.
/// architecture §4.2대로 Isar로 교체(진척·오답·세션 영속화). 승인 후 후속 작업.
class LocalProgressDataSource {
  final Set<String> _wrong = <String>{};

  /// 오답 제거 규칙(MVP): 정답이면 즉시 제거.
  /// TODO(PRD 오픈이슈 1): '연속 N회 정답 시 제거' 규칙과 비교해 확정.
  void record(String id, {required bool correct}) {
    if (correct) {
      _wrong.remove(id);
    } else {
      _wrong.add(id);
    }
  }

  Set<String> wrongIds() => {..._wrong};

  void clear(String id) => _wrong.remove(id);
}
