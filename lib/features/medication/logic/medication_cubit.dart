import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/medication_repository.dart';

// --- State ---
class MedicationState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  MedicationState({this.isLoading = false, this.isSuccess = false, this.error});
}

// --- Cubit ---
class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRepository repository;

  MedicationCubit({required this.repository}) : super(MedicationState()) {
    repository.requestPermissions();
  }

  // إضافة من تطبيق المريض
  Future<void> addPatientMedication({
    required BuildContext context,
    required String patientID,
    required String name,
    required String dose,
    required TimeOfDay time,
    required List<String> days,
  }) async {
    emit(MedicationState(isLoading: true));
    try {
      final data = {
        'name': name,
        'dosage': dose,
        'time': time.format(context),
        'hour': time.hour,             // حفظ الساعة كرقم لحل مشكلة المزامنة
        'minute': time.minute,         // حفظ الدقيقة كرقم لحل مشكلة المزامنة
        'days': days,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await repository.addMedicationForPatient(patientID, data);
      await repository.scheduleWeeklyNotifications(name, dose, time, days);

      emit(MedicationState(isSuccess: true));
    } catch (e) {
      emit(MedicationState(error: e.toString()));
    }
  }

  // إضافة من تطبيق العائلة
  Future<void> addFamilyMedication({
    required BuildContext context,
    required String patientID,
    required String name,
    required String dose,
    required TimeOfDay time,
    required String frequency,
  }) async {
    emit(MedicationState(isLoading: true));
    try {
      final data = {
        'name': name,
        'dosage': dose,
        'time': time.format(context),
        'hour': time.hour,             // حفظ الساعة كرقم لحل مشكلة المزامنة
        'minute': time.minute,         // حفظ الدقيقة كرقم لحل مشكلة المزامنة
        'frequency': frequency,
        'createdAt': Timestamp.now(),
      };

      await repository.addMedicationFromFamily(patientID, data);
      emit(MedicationState(isSuccess: true));
    } catch (e) {
      emit(MedicationState(error: e.toString()));
    }
  }

  Future<void> editMedication(String patientID, String docID, String name, String dose) async {
    try {
      await repository.updateMedication(patientID, docID, {
        'name': name,
        'dosage': dose,
      });
    } catch (e) {
      emit(MedicationState(error: e.toString()));
    }
  }

  Future<void> deleteMedication(String patientID, String docID) async {
    try {
      await repository.deleteMedication(patientID, docID);
    } catch (e) {
      emit(MedicationState(error: e.toString()));
    }
  }
}