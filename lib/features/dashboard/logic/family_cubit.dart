import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/notification_service.dart';
import '../data/dashboard_repository.dart';

// --- State ---
class FamilyDashboardState {
  final bool isAlarmPlaying;
  final Set<String> acknowledgedAlerts;

  FamilyDashboardState({this.isAlarmPlaying = false, this.acknowledgedAlerts = const {}});

  FamilyDashboardState copyWith({bool? isAlarmPlaying, Set<String>? acknowledgedAlerts}) {
    return FamilyDashboardState(
      isAlarmPlaying: isAlarmPlaying ?? this.isAlarmPlaying,
      acknowledgedAlerts: acknowledgedAlerts ?? this.acknowledgedAlerts,
    );
  }
}

// --- Cubit ---
class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  final DashboardRepository repository;
  final String patientID;
  StreamSubscription? _alertSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();

  FamilyDashboardCubit({required this.repository, required this.patientID})
      : super(FamilyDashboardState()) {
    _init();
  }

  void _init() async {
    NotificationService.initialize();
    final prefs = await SharedPreferences.getInstance();
    final ackAlerts = (prefs.getStringList('ack_alerts') ?? []).toSet();
    emit(state.copyWith(acknowledgedAlerts: ackAlerts));
    _listenToAlerts();
  }

  void _listenToAlerts() {
    // تم الإصلاح هنا: تمرير الحد الأقصى كـ Parameter للـ Repository
    _alertSubscription = repository.getPatientAlertsStream(patientID, queryLimit: 1)
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp? ts = data['timestamp'] as Timestamp?;
      if (ts == null) return;

      final diff = DateTime.now().difference(ts.toDate()).inMinutes;
      final isEmergency = data['type'] == "EMERGENCY";
      final isNew = !state.acknowledgedAlerts.contains(doc.id);

      if (isNew && diff < 10 && isEmergency) {
        _startAlarm();
        NotificationService.showEmergencyNotification(
          title: "حالة طوارئ عاجلة!",
          body: data['message'] ?? "الرجاء فحص المريض فوراً",
        );
      } else if (!isEmergency || diff >= 10) {
        _stopAlarm();
      }
    });
  }

  void _startAlarm() async {
    if (!state.isAlarmPlaying) {
      emit(state.copyWith(isAlarmPlaying: true));
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/alarm.wav'));
      } catch (e) {
        // Handle error
      }
    }
  }

  void _stopAlarm() {
    if (state.isAlarmPlaying) {
      emit(state.copyWith(isAlarmPlaying: false));
      _audioPlayer.stop();
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final newAck = Set<String>.from(state.acknowledgedAlerts)..add(alertId);
    emit(state.copyWith(acknowledgedAlerts: newAck));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ack_alerts', newAck.toList());
    _stopAlarm();
  }

  @override
  Future<void> close() {
    _alertSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}