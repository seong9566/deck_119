import 'dart:async';

import '../entities/quiz_mode.dart';
import '../entities/recent_session.dart';

/// 저장된 세션 스냅샷. [questionIds]가 비었으면 저장소 순서를 그대로 쓴다
/// (v4 이전 세션 하위호환).
typedef SessionSnapshot = ({
  int lastIndex,
  List<int?> answers,
  List<String> questionIds,
});

/// 이어풀기 세션(쓰기) 포트. 카테고리 ⨯ 모드 단위로 분리 보관한다.
abstract interface class SessionRepository {
  /// 저장된 세션(마지막 위치 + 문항별 선택 + 출제 목록). 없으면 null.
  Future<SessionSnapshot?> load(String categoryId, QuizMode mode);

  /// 최근 갱신순 세션 목록(홈 이어풀기용). 최신이 앞.
  /// [categoryId]를 주면 그 카테고리의 세션만(모드 무관).
  Future<List<RecentSession>> recentSessions({int limit, String? categoryId});

  /// 최근 갱신순 세션 목록 스트림(홈 이어풀기용). 최신이 앞.
  Stream<List<RecentSession>> watchRecentSessions({int limit});

  /// 세션 저장(upsert) — 마지막 위치, 문항별 선택(null = 미응답), 출제 목록.
  Future<void> save(
    String categoryId,
    QuizMode mode, {
    required int lastIndex,
    required List<int?> answers,
    required List<String> questionIds,
  });

  /// 세션 삭제(finish·제출 시).
  Future<void> clear(String categoryId, QuizMode mode);
}
