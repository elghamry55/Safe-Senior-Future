import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.actionId == 'ACK') {
          cancelAll(); // إيقاف الصوت وإغلاق الإشعار عند ضغط "تم الاستلام"
        }
      },
    );

    // 🚨 إنشاء قناة الإشعار برمجياً وتثبيت الصوت المخصص عليها
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'This channel is used for critical emergency alarms.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true, // تم حذف enableLighting لمنع الخطأ
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // الدالة الحالية جاهزة وتستقبل أي تنبيه طوارئ (سواء SOS أو سقوط)
  static Future<void> showEmergencyNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // لفتح الشاشة الحمراء تلقائياً حتى لو الهاتف مغلق
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      ongoing: true, // يمنع المستخدم من إزاحة الإشعار لإغلاقه عشوائياً
      autoCancel: false,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      actions: [
        AndroidNotificationAction(
          'ACK',
          'تم الاستلام',
          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}