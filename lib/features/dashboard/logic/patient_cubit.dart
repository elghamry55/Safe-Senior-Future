import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import '../data/dashboard_repository.dart';

// --- State ---
class PatientDashboardState {
  final String bpm;
  final String spo2;
  final String temp;

  PatientDashboardState({this.bpm = "--", this.spo2 = "--", this.temp = "--"});

  PatientDashboardState copyWith({String? bpm, String? spo2, String? temp}) {
    return PatientDashboardState(
      bpm: bpm ?? this.bpm,
      spo2: spo2 ?? this.spo2,
      temp: temp ?? this.temp,
    );
  }
}

// --- Cubit ---
class PatientDashboardCubit extends Cubit<PatientDashboardState> {
  final DashboardRepository repository;
  final String patientID;
  StreamSubscription<DatabaseEvent>? _vitalsSubscription;

  PatientDashboardCubit({required this.repository, required this.patientID})
      : super(PatientDashboardState()) {
    _init();
  }

  void _init() async {
    repository.enableOfflineMode();
    await _requestPermissions();
    await _fetchInitialVitals();
    _listenToVitals();
  }

  Future<void> _requestPermissions() async {
    await Future.delayed(const Duration(seconds: 2));
    await Permission.notification.request();
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _fetchInitialVitals() async {
    try {
      final snapshot = await repository.getInitialVitals();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        _updateStateFromData(data);
      }
    } catch (e) {
      // Silent catch
    }
  }

  void _listenToVitals() {
    _vitalsSubscription = repository.getVitalsStream().listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        _updateStateFromData(data);
      }
    });
  }

  void _updateStateFromData(Map data) {
    String newBpm = data['heartRate']?.toString() ?? "--";
    String newSpo2 = data['SPO2']?.toString() ?? "--";
    String newTemp = (data['temperature'] ?? data['temp'])?.toString() ?? "--";

    if (newBpm != "--" && newBpm != state.bpm) repository.saveVitalToHistory(patientID, "heartRate", newBpm);
    if (newSpo2 != "--" && newSpo2 != state.spo2) repository.saveVitalToHistory(patientID, "SPO2", newSpo2);
    if (newTemp != "--" && newTemp != state.temp) repository.saveVitalToHistory(patientID, "temp", newTemp);

    emit(state.copyWith(bpm: newBpm, spo2: newSpo2, temp: newTemp));
  }

  @override
  Future<void> close() {
    _vitalsSubscription?.cancel();
    return super.close();
  }
}