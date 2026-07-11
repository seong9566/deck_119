import 'package:isar/isar.dart';

part 'session_state.g.dart';

/// 이어풀기 세션 컬렉션(BUILD_PLAN §2). normal 모드 한정, 과목별 마지막 위치.
@collection
class SessionState {
  Id id = Isar.autoIncrement;

  /// 유일 키 = `"$subjectId:normal"`.
  @Index(unique: true, replace: true)
  late String key;

  late String subjectId;

  /// 마지막으로 머문 문항 인덱스(0-based).
  late int lastIndex;

  /// 문항별 선택 인덱스(길이 = 문항수, -1 = 미응답).
  /// 이어풀기 시 이전 세션의 선택·해설을 복원한다.
  late List<int> answers;

  /// 갱신 시각(epoch ms).
  late int updatedAtMs;
}
