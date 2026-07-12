import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/emergency_repository.dart';

// --- States ---
abstract class EmergencyState {}

class EmergencyInitial extends EmergencyState {}
class EmergencyLoading extends EmergencyState {}
class EmergencySuccess extends EmergencyState {}
class EmergencyFailure extends EmergencyState {
  final String error;
  EmergencyFailure(this.error);
}

// --- Cubit ---
class EmergencyCubit extends Cubit<EmergencyState> {
  final EmergencyRepository repository;

  EmergencyCubit({required this.repository}) : super(EmergencyInitial());

  Future<void> sendSOS({required String patientID, required String name}) async {
    emit(EmergencyLoading());
    try {
      await repository.sendSOSAlert(patientID: patientID, name: name);
      emit(EmergencySuccess());
    } catch (e) {
      emit(EmergencyFailure(e.toString()));
    }
  }
}