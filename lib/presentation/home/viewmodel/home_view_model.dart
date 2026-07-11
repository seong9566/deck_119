import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/question_collection.dart';
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

/// 선택 가능한 문제 세트 목록(원형 회차별·심화·전체).
final collectionsProvider =
    FutureProvider<List<QuestionCollection>>((ref) async {
  return ref.watch(questionRepositoryProvider).getCollections();
});

/// 과목별 이어풀기 정보(있으면 홈에 진입점 노출). 풀이에서 돌아오면 invalidate.
final resumeInfoProvider =
    FutureProvider.autoDispose.family<ResumeInfo?, String>((ref, subjectId) {
  return ref.watch(getResumeInfoProvider)(subjectId);
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
    FutureProvider.autoDispose.family<SubjectStats, String>((ref, subjectId) async {
  final qs = await ref.watch(questionRepositoryProvider).getQuestions(subjectId);
  return SubjectStats(
    total: qs.length,
    mcq: qs.where((q) => q.type == QuestionType.mcq).length,
    ox: qs.where((q) => q.type == QuestionType.ox).length,
  );
});
