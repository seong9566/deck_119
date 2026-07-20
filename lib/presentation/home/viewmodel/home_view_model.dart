import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/progress_stats.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/question_category.dart';
import '../../../domain/entities/resume_info.dart';
import '../../../domain/entities/subject.dart';

/// 홈 ViewModel — 과목 목록을 로드한다(MVP는 단일 과목).
final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, List<Subject>>(HomeViewModel.new);

class HomeViewModel extends AsyncNotifier<List<Subject>> {
  @override
  Future<List<Subject>> build() async {
    return ref.watch(questionRepositoryProvider).getSubjects();
  }
}

/// 선택 가능한 카테고리 목록(법령별·교차법령·심화 OX·계산 + 전체).
final categoriesProvider =
    FutureProvider<List<QuestionCategory>>((ref) async {
  return ref.watch(questionRepositoryProvider).getCategories();
});

/// 과목별 이어풀기 정보(있으면 홈에 진입점 노출). 풀이에서 돌아오면 invalidate.
final resumeInfoProvider =
    FutureProvider.autoDispose.family<ResumeInfo?, String>((ref, categoryId) {
  return ref.watch(getResumeInfoProvider)(categoryId);
});

/// 과목 문항 통계(실측 — §3-1 하드코딩 금지). 홈/과목 화면 메타·모드 설명에 사용.
class SubjectStats {
  final int total;
  final int mcq;
  final int ox;
  const SubjectStats({required this.total, required this.mcq, required this.ox});

  /// "객관식 N · OX M · 총 K문항"(OX 0이면 생략) — 실제 로드된 수 기반.
  String get meta {
    final parts = <String>[
      if (mcq > 0) '객관식 $mcq',
      if (ox > 0) 'OX $ox',
    ];
    final head = parts.isEmpty ? '' : '${parts.join(' · ')} · ';
    return '$head총 $total문항';
  }
}

final subjectStatsProvider =
    FutureProvider.autoDispose.family<SubjectStats, String>((ref, categoryId) async {
  final qs = await ref.watch(questionRepositoryProvider).getQuestions(categoryId);
  return SubjectStats(
    total: qs.length,
    mcq: qs.where((q) => q.type == QuestionType.mcq).length,
    ox: qs.where((q) => q.type == QuestionType.ox).length,
  );
});

/// 시도 이력 테이블 구독 — 어디서 풀든 홈 진척 통계에 실시간 반영.
final progressStatsProvider = StreamProvider.autoDispose<ProgressStats>((ref) {
  return ref.watch(progressRepositoryProvider).watchStats();
});

/// 오답 테이블 구독 — 어디서 풀든 홈 오답 개수에 실시간 반영.
final wrongCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(progressRepositoryProvider)
      .watchWrongIds()
      .map((ids) => ids.length);
});

/// AI 문제함 누적 개수(실시간). 0이면 홈 진입점을 숨긴다.
/// subjectId는 AI 생성 과목(fire-law) 고정.
final aiBankCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(generatedQuestionRepositoryProvider).watchCount('fire-law');
});

/// 회수 안전망: 홈 진입 시 타임아웃으로 못 받았던 완료분을 적립함에 흡수한다.
/// 반환=이번에 회수된 문항 수. 저장하면 aiBankCountProvider가 자동 갱신된다.
final aiRecoveryProvider = FutureProvider.autoDispose<int>((ref) async {
  final recovered =
      await ref.watch(aiQuestionRepositoryProvider).recoverCompleted();
  if (recovered.isNotEmpty) {
    await ref.watch(generatedQuestionRepositoryProvider).save(recovered);
  }
  return recovered.length;
});

/// 홈 "이어풀기" 카드(가장 최근 세션 → 표시용 세트 정보). 없으면 null.
class RecentSessionCard {
  final String collectionId;
  final String name;
  final int position; // 1-based
  final int total;
  const RecentSessionCard({
    required this.collectionId,
    required this.name,
    required this.position,
    required this.total,
  });
}

/// 세션 테이블 구독 — 어디서 풀든 홈 이어풀기에 실시간 반영.
final recentSessionCardProvider =
    StreamProvider.autoDispose<RecentSessionCard?>((ref) async* {
  final collections =
      await ref.watch(questionRepositoryProvider).getCategories();
  yield* ref
      .watch(sessionRepositoryProvider)
      .watchRecentSessions(limit: 1)
      .map((sessions) {
    if (sessions.isEmpty) return null;
    final s = sessions.first;
    QuestionCategory? col;
    for (final c in collections) {
      if (c.id == s.collectionId) {
        col = c;
        break;
      }
    }
    if (col == null) return null; // 세트 구성 변경 등으로 매칭 실패
    return RecentSessionCard(
      collectionId: col.id,
      name: col.name,
      position: s.lastIndex + 1,
      total: col.count,
    );
  });
});
