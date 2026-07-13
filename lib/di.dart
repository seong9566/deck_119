import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/app_router.dart';

import 'data/datasources/content_data_source.dart';
import 'data/repositories/ai_question_repository_impl.dart';
import 'domain/repositories/ai_question_repository.dart';
import 'data/datasources/local/app_database.dart';
import 'data/datasources/local/drift_generated_data_source.dart';
import 'data/datasources/local/drift_pending_ai_data_source.dart';
import 'data/datasources/local/drift_progress_data_source.dart';
import 'data/datasources/local/drift_session_data_source.dart';
import 'data/datasources/local/drift_settings_data_source.dart';
import 'data/repositories/generated_question_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/question_repository_impl.dart';
import 'data/repositories/session_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/generated_question_repository.dart';
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

/// Drift DB. `main()`에서 open 후 ProviderScope override로 주입한다.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) =>
      throw UnimplementedError('appDatabaseProvider must be overridden in main()'),
);

/// go_router. ProviderScope 단위로 1개(테스트 격리 + 앱 내 안정).
final routerProvider = Provider<GoRouter>((ref) => createRouter());

// DataSource
final _contentDataSourceProvider = Provider((ref) => ContentDataSource());
final _progressDataSourceProvider =
    Provider((ref) => DriftProgressDataSource(ref.watch(appDatabaseProvider)));
final _sessionDataSourceProvider =
    Provider((ref) => DriftSessionDataSource(ref.watch(appDatabaseProvider)));
final _settingsDataSourceProvider =
    Provider((ref) => DriftSettingsDataSource(ref.watch(appDatabaseProvider)));
final _generatedDataSourceProvider =
    Provider((ref) => DriftGeneratedDataSource(ref.watch(appDatabaseProvider)));
final _pendingAiDataSourceProvider =
    Provider((ref) => DriftPendingAiDataSource(ref.watch(appDatabaseProvider)));

// Repository (port ← impl)
final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => QuestionRepositoryImpl(ref.watch(_contentDataSourceProvider)),
);
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(_progressDataSourceProvider)),
);
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepositoryImpl(ref.watch(_sessionDataSourceProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(_settingsDataSourceProvider)),
);

/// AI 문제 생성 저장소(Firestore 큐 중계 → 맥북 워커가 CLI로 생성).
/// 기본 `(default)`가 아니라 명명된 DB(`deck-119-db`)를 사용.
/// 10문항 생성은 오래 걸려 대기 상한을 240초로 둔다(초과분은 회수 안전망으로 흡수).
final aiQuestionRepositoryProvider = Provider<AiQuestionRepository>(
  (ref) => AiQuestionRepositoryImpl(
    FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'deck-119-db',
    ),
    ref.watch(_pendingAiDataSourceProvider),
    timeout: const Duration(seconds: 240),
  ),
);

/// AI 생성 문항 적립함(로컬 Drift 누적 보관 → 재풀이 제공).
final generatedQuestionRepositoryProvider =
    Provider<GeneratedQuestionRepository>(
  (ref) =>
      GeneratedQuestionRepositoryImpl(ref.watch(_generatedDataSourceProvider)),
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
