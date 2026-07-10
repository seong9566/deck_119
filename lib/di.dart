import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'data/datasources/content_data_source.dart';
import 'data/datasources/local/isar_progress_data_source.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/question_repository_impl.dart';
import 'domain/repositories/progress_repository.dart';
import 'domain/repositories/question_repository.dart';
import 'domain/usecases/get_question_set.dart';
import 'domain/usecases/submit_answer.dart';

/// 의존성 주입(조립). Presentation은 UseCase만 watch하고 구현을 모른다.

/// Isar 인스턴스. `main()`에서 open 후 ProviderScope override로 주입한다.
final isarProvider = Provider<Isar>(
  (ref) => throw UnimplementedError('isarProvider must be overridden in main()'),
);

// DataSource
final _contentDataSourceProvider = Provider((ref) => ContentDataSource());
final _isarProgressDataSourceProvider =
    Provider((ref) => IsarProgressDataSource(ref.watch(isarProvider)));

// Repository (port ← impl)
final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => QuestionRepositoryImpl(ref.watch(_contentDataSourceProvider)),
);
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(_isarProgressDataSourceProvider)),
);

// UseCase
final getQuestionSetProvider = Provider(
  (ref) => GetQuestionSet(
    ref.watch(questionRepositoryProvider),
    ref.watch(progressRepositoryProvider),
  ),
);
final submitAnswerProvider = Provider(
  (ref) => SubmitAnswer(ref.watch(progressRepositoryProvider)),
);
