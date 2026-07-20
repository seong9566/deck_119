import 'package:deck_119/data/datasources/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v3→v4 업그레이드 시 sessions 클리어', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // 구 키 형식 세션 주입.
    await db.into(db.sessions).insert(SessionsCompanion.insert(
          key: 'fire-law::2026-1회:normal',
          subjectId: 'fire-law::2026-1회',
          lastIndex: 3,
          answers: '0,1,2',
          updatedAtMs: 1,
        ));
    // v3→v4 마이그레이션 수동 실행.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    final m = db.createMigrator();
    await db.migration.onUpgrade(m, 3, 4);

    final rows = await db.select(db.sessions).get();
    expect(rows, isEmpty);
    await db.close();
  });
}
