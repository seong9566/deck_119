import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

import 'presentation/app_router.dart';

import 'data/datasources/content_data_source.dart';
import 'data/datasources/local/isar_progress_data_source.dart';
import 'data/datasources/local/isar_session_data_source.dart';
import 'data/datasources/local/isar_settings_data_source.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/question_repository_impl.dart';
import 'data/repositories/session_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/progress_repository.dart';
import 'domain/repositories/question_repository.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/clear_session.dart';
import 'domain/usecases/get_question_set.dart';
import 'domain/usecases/get_resume_info.dart';
import 'domain/usecases/get_theme_mode.dart';
import 'domain/usecases/save_session_position.dart';
import 'domain/usecases/set_theme_mode.dart';
import 'domain/usecases/submit_answer.dart';

/// 의존성 주입(조립). Presentation은 UseCase만 watch하고 구현을 모른다.

/// Isar 인스턴스. `main()`에서 open 후 ProviderScope override로 주입한다.
final isarProvider = Provider<Isar>(
  (ref) => throw UnimplementedError('isarProvider must be overridden in main()'),
);

/// go_router. ProviderScope 단위로 1개(테스트 격리 + 앱 내 안정).
final routerProvider = Provider<GoRouter>((ref) => createRouter());

// DataSource
final _contentDataSourceProvider = Provider((ref) => ContentDataSource());
final _isarProgressDataSourceProvider =
    Provider((ref) => IsarProgressDataSource(ref.watch(isarProvider)));
final _isarSessionDataSourceProvider =
    Provider((ref) => IsarSessionDataSource(ref.watch(isarProvider)));
final _isarSettingsDataSourceProvider =
    Provider((ref) => IsarSettingsDataSource(ref.watch(isarProvider)));

// Repository (port ← impl)
final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => QuestionRepositoryImpl(ref.watch(_contentDataSourceProvider)),
);
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(_isarProgressDataSourceProvider)),
);
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepositoryImpl(ref.watch(_isarSessionDataSourceProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(_isarSettingsDataSourceProvider)),
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
final getResumeInfoProvider = Provider(
  (ref) => GetResumeInfo(
    ref.watch(questionRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final saveSessionPositionProvider = Provider(
  (ref) => SaveSessionPosition(ref.watch(sessionRepositoryProvider)),
);
final clearSessionProvider = Provider(
  (ref) => ClearSession(ref.watch(sessionRepositoryProvider)),
);
final getThemeModeProvider = Provider(
  (ref) => GetThemeMode(ref.watch(settingsRepositoryProvider)),
);
final setThemeModeProvider = Provider(
  (ref) => SetThemeMode(ref.watch(settingsRepositoryProvider)),
);
