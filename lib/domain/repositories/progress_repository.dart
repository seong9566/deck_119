import 'dart:async';

import '../entities/progress_stats.dart';

/// 진척·오답(쓰기) 포트. 구현은 data 레이어.
/// MVP 스캐폴드는 인메모리 구현, 이후 Isar로 교체(architecture §4.2).
abstract interface class ProgressRepository {
  /// 채점 결과 기록. correct면 오답 세트에서 제거, 오답이면 추가.
  Future<void> recordAttempt(String questionId, {required bool correct});

  /// 여러 시도를 한 번에 기록(시험 제출용). 구현은 단일 트랜잭션으로 처리.
  Future<void> recordAttempts(List<({String questionId, bool correct})> attempts);

  /// 오답 세트(틀린 문제 id).
  Future<Set<String>> getWrongIds();

  /// 오답 세트(틀린 문제 id) 스트림.
  Stream<Set<String>> watchWrongIds();

  /// 오답 세트에서 제거.
  Future<void> clearWrong(String questionId);

  /// 대시보드 진척 통계(시도 로그 집계). 정답률·연속학습·푼 문항 수.
  Future<ProgressStats> getStats();

  /// 대시보드 진척 통계 스트림.
  Stream<ProgressStats> watchStats();
}
