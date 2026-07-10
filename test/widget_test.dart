import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱이 뜨고 홈에 과목이 로드된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: Deck119App()));

    // 초기 로딩 스피너
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 에셋 JSON 로드 완료 후 과목·모드 노출
    await tester.pumpAndSettle();
    expect(find.text('소방관계법규'), findsOneWidget);
    expect(find.text('전체 풀이'), findsOneWidget);
  });
}
