import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/question.dart';

/// 생성 옵션(화면 로컬 선택값).
typedef AiGenOptions = ({String yearScope, int count, String type});

/// AI 생성 세트를 풀이 화면으로 넘기는 핸드오프 홀더(autoDispose 아님 — 생성 페이지가
/// pop돼도 유지). 퀴즈(ai 모드)가 build 시 여기서 읽는다.
final generatedQuestionsProvider =
    StateProvider<List<Question>>((ref) => const []);
