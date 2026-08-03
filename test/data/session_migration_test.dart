import 'dart:io';

import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 구 버전 스키마·데이터를 raw로 구성하고 user_version을 낮춰두면
/// drift가 DB를 열면서 최신(v5)까지 마이그레이션한다.
AppDatabase _openAtVersion(int version, {String? seedSession}) {
  return AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
    raw.execute('''
      CREATE TABLE sessions (
        key TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        last_index INTEGER NOT NULL,
        answers TEXT NOT NULL,
        updated_at_ms INTEGER NOT NULL,
        PRIMARY KEY (key)
      )
    ''');
    if (seedSession != null) raw.execute(seedSession);
    raw.execute('PRAGMA user_version = $version');
  }));
}

void main() {
  test('v3에서 올라오면 구 키 세션이 클리어된다', () async {
    final db = _openAtVersion(
      3,
      seedSession: "INSERT INTO sessions "
          "VALUES ('fire-law::2026-1회:normal', 'fire-law::2026-1회', 3, '0,1,2', 1)",
    );

    expect(await db.select(db.sessions).get(), isEmpty);
    await db.close();
  });

  test('v4→v5: 기존 세션 보존 + mode 기본값 + ai_answers 생성', () async {
    final db = _openAtVersion(
      4,
      seedSession:
          "INSERT INTO sessions VALUES ('s1:normal', 's1', 3, '0,1,2,-1', 100)",
    );

    final rows = await db.select(db.sessions).get();
    expect(rows.length, 1, reason: '진행 중이던 세션은 삭제되지 않는다');
    expect(rows.first.key, 's1:normal');
    expect(rows.first.lastIndex, 3);
    expect(rows.first.answers, '0,1,2,-1');
    expect(rows.first.mode, 'normal', reason: '구 세션은 전체 풀이로 간주');
    expect(rows.first.questionIds, '', reason: '빈 값 = 저장소 순서 사용');

    expect(await db.select(db.aiAnswers).get(), isEmpty);
    await db.close();
  });

  test('v4→v5: 중간 실패 후 재실행해도 나머지 스키마를 완성한다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE sessions (
          key TEXT NOT NULL,
          subject_id TEXT NOT NULL,
          last_index INTEGER NOT NULL,
          answers TEXT NOT NULL,
          updated_at_ms INTEGER NOT NULL,
          PRIMARY KEY (key)
        )
      ''');
      raw.execute(
        "ALTER TABLE sessions ADD COLUMN mode TEXT NOT NULL DEFAULT 'normal'",
      );
      raw.execute('PRAGMA user_version = 4');
    }));

    final rows = await db.select(db.sessions).get();
    expect(rows, isEmpty);
    expect(await db.select(db.aiAnswers).get(), isEmpty);
    await db.close();
  });

  test('v5→v4→v5: 기존 sessions 행을 보존하며 재업그레이드한다', () async {
    final dir = await Directory.systemTemp.createTemp('session_migration');
    final file = File('${dir.path}/session.sqlite');
    addTearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    final db1 = AppDatabase.forTesting(NativeDatabase(file));
    await db1.select(db1.sessions).get();
    await db1.customStatement(
      "INSERT INTO sessions "
      "VALUES ('s1:normal', 's1', 'normal', '', 3, '0,1,2,-1', 100)",
    );
    await db1.customStatement('PRAGMA user_version = 4');
    await db1.close();

    final db2 = AppDatabase.forTesting(NativeDatabase(file));
    final rows = await db2.select(db2.sessions).get();
    expect(rows.length, 1);
    expect(rows.first.key, 's1:normal');
    await db2.close();
  });
}
