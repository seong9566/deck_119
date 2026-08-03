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

/// 이어풀기 세션(모드별). key = `"$categoryId:$mode"`.
/// [answers]는 문항별 선택 인덱스(-1 = 미응답)를 CSV로 직렬화해 보관.
/// [questionIds]는 출제된 문항 id 목록(JSON 배열) — random·quick·review처럼
/// 세트가 매번 달라지는 모드를 같은 순서로 복원하려면 목록 자체가 필요하다.
/// 빈 문자열이면 저장소 순서를 그대로 쓴다(v4 이전 세션 하위호환).
class Sessions extends Table {
  TextColumn get key => text()();
  TextColumn get subjectId => text()();
  TextColumn get mode => text().withDefault(const Constant('normal'))();
  TextColumn get questionIds => text().withDefault(const Constant(''))();
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

/// AI 생성 문항 적립함(참고용). 번들에 없는 합성 문항이라 내용 전체를
/// [payload](Question JSON)로 보관한다. 생성할 때마다 append돼 누적된다.
class GeneratedQuestions extends Table {
  /// 합성 id(`ai-<us>-<i>`). 유일.
  TextColumn get id => text()();
  TextColumn get subjectId => text()();

  /// Question 전체를 직렬화한 JSON(QuestionDto.fromJson으로 복원).
  TextColumn get payload => text()();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 회수 대기 중인 생성 요청(타임아웃 안전망). 앱이 만든 gen_requests doc id를
/// 보관했다가, 홈 진입 시 done된 것을 회수해 적립함에 넣는다.
class PendingAiRequests extends Table {
  /// Firestore gen_requests doc id.
  TextColumn get docId => text()();
  TextColumn get subjectId => text()();

  /// 회수 시 year 매핑에 필요("2025"|"2026"|"all").
  TextColumn get yearScope => text()();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column> get primaryKey => {docId};
}

/// AI 생성 문항의 풀이 기록. questionId 유일(재응답 시 덮어씀).
/// 통계·오답노트(AttemptRecords·WrongEntries)와 분리해 합성 id가 기출 지표를
/// 오염시키지 않게 한다(ADR-0002). AI 문제함의 "이미 푼 문항" 판정 원천.
class AiAnswers extends Table {
  TextColumn get questionId => text()();
  TextColumn get subjectId => text()();
  IntColumn get selectedIndex => integer()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get answeredAtMs => integer()();

  @override
  Set<Column> get primaryKey => {questionId};
}

@DriftDatabase(tables: [
  AttemptRecords,
  WrongEntries,
  Sessions,
  Settings,
  GeneratedQuestions,
  PendingAiRequests,
  AiAnswers,
])
class AppDatabase extends _$AppDatabase {
  /// 앱 실행용(문서 디렉터리에 deck119.sqlite).
  AppDatabase() : super(driftDatabase(name: 'deck119'));

  /// 테스트용(인메모리 등 executor 주입).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2: AI 생성 문항 적립함 추가.
          if (from < 2) await m.createTable(generatedQuestions);
          // v3: 회수 대기 요청 테이블 추가.
          if (from < 3) await m.createTable(pendingAiRequests);
          // v4: 분류를 법령 카테고리로 재편 → 구 키 세션 클리어(T20).
          if (from < 4) await customStatement('DELETE FROM sessions');
          // v5: 세션을 전 모드로 확장 + AI 풀이 기록 테이블 추가.
          // 기존 행은 key가 이미 ":normal"이라 mode 기본값과 일치 → 삭제하지 않는다.
          if (from < 5) {
            // 중간 실패나 다운그레이드 후 재실행 시 일부 컬럼이 이미 남아 있을 수 있다.
            // SQLite의 ADD COLUMN은 IF NOT EXISTS를 지원하지 않으므로 실제 컬럼만 추가한다.
            final columns = await m.database
                .customSelect('PRAGMA table_info(sessions)')
                .get();
            final columnNames =
                columns.map((row) => row.read<String>('name')).toSet();
            if (!columnNames.contains('mode')) {
              await m.addColumn(sessions, sessions.mode);
            }
            if (!columnNames.contains('question_ids')) {
              await m.addColumn(sessions, sessions.questionIds);
            }
            await m.createTable(aiAnswers);
          }
        },
      );
}
