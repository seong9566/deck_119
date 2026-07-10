import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';

/// 테스트에서 Isar 네이티브 코어를 초기화한다.
///
/// TestWidgetsFlutterBinding이 HTTP를 막아 `download: true`가 실패하므로,
/// 사전에 받아둔 `build/isar/libisar.dylib`(gitignore)를 로컬 로드한다.
/// 없으면 최후로 다운로드를 시도한다(오프라인 환경에선 실패 — BUILD_LOG T2 참고).
Future<void> initIsarTestCore() async {
  final local = File('${Directory.current.path}/build/isar/libisar.dylib');
  if (local.existsSync()) {
    await Isar.initializeIsarCore(
      libraries: {
        Abi.macosArm64: local.path,
        Abi.macosX64: local.path,
      },
    );
  } else {
    await Isar.initializeIsarCore(download: true);
  }
}
