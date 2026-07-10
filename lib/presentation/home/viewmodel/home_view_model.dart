import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
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

/// 과목별 이어풀기 정보(있으면 홈에 진입점 노출). 풀이에서 돌아오면 invalidate.
final resumeInfoProvider =
    FutureProvider.autoDispose.family<ResumeInfo?, String>((ref, subjectId) {
  return ref.watch(getResumeInfoProvider)(subjectId);
});
