import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract interface class NotificationService {
  /// 앱 시작 시 1회 초기화. [onTapHome]은 알림 탭 시 홈으로 이동하는 콜백이다.
  Future<void> init({void Function()? onTapHome});

  /// 소방 문제 [count]개 생성 완료 알림을 표시한다.
  Future<void> showDone(int count);

  /// 생성 실패 알림을 표시한다.
  Future<void> showError();
}

class LocalNotificationService implements NotificationService {
  static const _channelId = 'deck119_gen';
  static const _channelName = '문제 생성';

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init({void Function()? onTapHome}) async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (_) => onTapHome?.call(),
      );
    } catch (_) {
      // 플랫폼 미지원이나 초기화 실패가 앱 시작을 막지 않게 한다.
    }

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      // 권한 거부나 요청 실패와 무관하게 앱을 계속 실행한다.
    }

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {
      // 권한 거부나 요청 실패와 무관하게 앱을 계속 실행한다.
    }

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              importance: Importance.high,
            ),
          );
    } catch (_) {
      // 채널을 지원하지 않는 플랫폼에서도 앱을 계속 실행한다.
    }
  }

  @override
  Future<void> showDone(int count) =>
      _show(id: 1001, title: '문제 생성 완료', body: '소방 문제 $count개가 완성됐어요!');

  @override
  Future<void> showError() =>
      _show(id: 1002, title: '문제 생성 실패', body: '잠시 후 다시 시도해 주세요.');

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _notificationDetails,
      );
    } catch (_) {
      // 권한이 없거나 플랫폼이 지원되지 않아도 앱을 계속 실행한다.
    }
  }
}
