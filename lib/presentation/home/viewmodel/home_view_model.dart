import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
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
