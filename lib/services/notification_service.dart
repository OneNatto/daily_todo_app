import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Priority;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notifications show Priority;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/todo.dart';
import '../core/utils/date_utils.dart';

/// 通知サービス
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    // タイムゾーンの初期化
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  /// 通知がタップされた時の処理
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: 必要に応じてナビゲーション処理を追加
  }

  /// 通知パーミッションをリクエスト
  Future<bool> requestPermission() async {
    // Android
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// ToDoリマインダー通知をスケジュール
  Future<void> scheduleReminder(Todo todo) async {
    if (todo.reminderDateTime == null) return;
    if (todo.reminderDateTime!.isBefore(DateTime.now())) return;

    final id = todo.id.hashCode;

    final androidDetails = AndroidNotificationDetails(
      'todo_reminders',
      'ToDoリマインダー',
      channelDescription: 'ToDoのリマインダー通知',
      importance: Importance.high,
      priority: notifications.Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(todo.reminderDateTime!, tz.local);
    final formattedDate = todo.dueDate != null
        ? AppDateUtils.formatRelativeDate(todo.dueDate!)
        : '';

    await _plugin.zonedSchedule(
      id,
      'ToDoリマインダー',
      '${todo.title}${formattedDate.isNotEmpty ? ' - $formattedDate' : ''}',
      scheduledDate,
      details,
      payload: todo.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 通知をキャンセル
  Future<void> cancelReminder(String todoId) async {
    final id = todoId.hashCode;
    await _plugin.cancel(id);
  }

  /// すべての通知をキャンセル
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  /// 即時通知を表示（テスト用）
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'お知らせ',
      channelDescription: '一般的なお知らせ',
      importance: Importance.high,
      priority: notifications.Priority.high,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}

