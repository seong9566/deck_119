import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/entities/question.dart';

/// 생성 옵션(화면 로컬 선택값).
typedef AiGenOptions = ({String yearScope, int count, String type});

/// AI 생성 세트를 풀이 화면으로 넘기는 핸드오프 홀더(autoDispose 아님 — 생성 페이지가
/// pop돼도 유지). 퀴즈(ai 모드)가 build 시 여기서 읽는다.
final generatedQuestionsProvider =
    StateProvider<List<Question>>((ref) => const []);

/// 생성 액션 상태. null=대기, loading=생성 중, data(non-null)=성공, error=실패.
final aiGenProvider =
    AutoDisposeAsyncNotifierProvider<AiGenViewModel, List<Question>?>(
  AiGenViewModel.new,
);

class AiGenViewModel extends AutoDisposeAsyncNotifier<List<Question>?> {
  @override
  Future<List<Question>?> build() async => null; // 대기 상태

  /// 옵션으로 생성 호출. 성공 시 핸드오프 홀더에 저장하고 결과를 state로 노출.
  Future<void> run({
    required String subjectId,
    required AiGenOptions options,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final questions = await ref.read(aiQuestionRepositoryProvider).generate(
            subjectId: subjectId,
            yearScope: options.yearScope,
            count: options.count,
            type: options.type,
          );
      // 생성분을 적립함에 누적 저장(참고용). 재풀이는 여기서 로드된다.
      if (questions.isNotEmpty) {
        await ref.read(generatedQuestionRepositoryProvider).save(questions);
      }
      ref.read(generatedQuestionsProvider.notifier).state = questions;
      return questions;
    });
  }
}
