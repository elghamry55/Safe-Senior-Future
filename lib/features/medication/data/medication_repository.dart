import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // --- Firebase Operations ---

  // حفظ دواء من تطبيق المريض (في Subcollection)
  Future<void> addMedicationForPatient(String patientID, Map<String, dynamic> data) async {
    await _firestore
        .collection('patients')
        .doc(patientID)
        .collection('medications')
        .add(data);
  }

  // حفظ دواء من تطبيق العائلة (في Array)
// عدل الدالة دي في تطبيق الأهل لتكون بالشكل ده:
  Future<void> addMedicationFromFamily(String patientID, Map<String, dynamic> data) async {
    // بدلاً من استخدام update مع arrayUnion، استخدم add في الـ sub-collection
    await _firestore
        .collection('patients')
        .doc(patientID)
        .collection('medications') // نفس الاسم اللي التابلت بيستخدمه
        .add(data);
  }
  Stream<QuerySnapshot> getMedicationsStream(String patientID) {
    return _firestore
        .collection('patients')
        .doc(patientID)
        .collection('medications')
        .orderBy('time')
        .snapshots();
  }

  Future<void> updateMedication(String patientID, String docID, Map<String, dynamic> data) async {
    await _firestore
        .collection('patients')
        .doc(patientID)
        .collection('medications')
        .doc(docID)
        .update(data);
  }

  Future<void> deleteMedication(String patientID, String docID) async {
    await _firestore
        .collection('patients')
        .doc(patientID)
        .collection('medications')
        .doc(docID)
        .delete();
  }

  // --- Notifications Operations ---

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleWeeklyNotifications(String name, String dose, TimeOfDay time, List<String> selectedDays) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'medication_channel',
        'تنبيهات الأدوية',
        channelDescription: 'تذكير بمواعيد الدواء',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      for (var day in selectedDays) {
        int weekdayIndex = _getWeekdayIndex(day);
        var now = DateTime.now();
        var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

        while (scheduledDate.weekday != weekdayIndex) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        await _notificationsPlugin.zonedSchedule(
          (name + day).hashCode,
          '💊 موعد دواء: $name',
          'الجرعة: $dose الآن',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e) {
      debugPrint("❌ خطأ في التنبيهات: $e");
    }
  }

  int _getWeekdayIndex(String day) {
    Map<String, int> daysMap = {
      "الاثنين": 1, "الثلاثاء": 2, "الأربعاء": 3, "الخميس": 4, "الجمعة": 5, "السبت": 6, "الأحد": 7
    };
    return daysMap[day] ?? 1;
  }
}