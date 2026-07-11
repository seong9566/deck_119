import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// 시도 이력(진척). 채점 때마다 append(오답 리뷰·통계 원천).
class AttemptRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get questionId => text()();
  BoolColumn get isCorrect => boolean()();

  /// 시도 시각(epoch ms).
  IntColumn get timestampMs => integer()();

  // 인터페이스 경계에서 전달 안 되면 null(통계 스키마 자리).
  TextColumn get subjectId => text().nullable()();
  IntColumn get selectedIndex => integer().nullable()();
  TextColumn get mode => text().nullable()();
}

/// 오답 세트. questionId 유일(오답 발생 시 upsert, 정답 시 즉시 제거).
class WrongEntries extends Table {
  TextColumn get questionId => text()();
  IntColumn get addedAtMs => integer()();
  TextColumn get subjectId => text().nullable()();

  @override
  Set<Column> get primaryKey => {questionId};
}

/// 이어풀기 세션(normal 한정). key = `"$subjectId:normal"`.
/// [answers]는 문항별 선택 인덱스(-1 = 미응답)를 CSV로 직렬화해 보관.
class Sessions extends Table {
  TextColumn get key => text()();
  TextColumn get subjectId => text()();
  IntColumn get lastIndex => integer()();
  TextColumn get answers => text()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 앱 설정 단일 레코드(id 고정 0).
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get themeMode => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [AttemptRecords, WrongEntries, Sessions, Settings])
class AppDatabase extends _$AppDatabase {
  /// 앱 실행용(문서 디렉터리에 deck119.sqlite).
  AppDatabase() : super(driftDatabase(name: 'deck119'));

  /// 테스트용(인메모리 등 executor 주입).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
