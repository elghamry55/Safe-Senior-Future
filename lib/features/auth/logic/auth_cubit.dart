import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

// --- States ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthPatientSuccess extends AuthState {
  final String patientID;
  final String patientName;
  AuthPatientSuccess(this.patientID, this.patientName);
}
class AuthFamilySuccess extends AuthState {
  final String linkedPatientId;
  AuthFamilySuccess(this.linkedPatientId);
}
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// --- Cubit ---
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final data = await repository.checkLoginStatus();
    if (data != null) {
      if (data['role'] == 'family') {
        emit(AuthFamilySuccess(data['patientID'] ?? ''));
      } else {
        emit(AuthPatientSuccess(data['patientID'] ?? '', data['patientName'] ?? 'مريض'));
      }
    } else {
      emit(AuthInitial()); // لا يوجد تسجيل دخول مسبق
    }
  }

  Future<void> loginPatient(String patientID) async {
    emit(AuthLoading());
    try {
      final result = await repository.loginPatient(patientID);
      if (result != null) {
        emit(AuthPatientSuccess(result['patientID'], result['patientName']));
      } else {
        emit(AuthFailure("هذا الرقم غير مسجل لدينا"));
      }
    } catch (e) {
      emit(AuthFailure("عذراً، حدث خطأ في الاتصال"));
    }
  }

  Future<void> registerPatient({required String name, required String age, required String diseases}) async {
    emit(AuthLoading());
    try {
      final patientID = await repository.registerPatient(name, age, diseases);
      emit(AuthPatientSuccess(patientID, name));
    } catch (e) {
      emit(AuthFailure("حدث خطأ أثناء التسجيل: $e"));
    }
  }

  Future<void> registerFamilyMember({required String name, required String relation, required String patientId}) async {
    emit(AuthLoading());
    try {
      final exists = await repository.checkPatientExists(patientId);
      if (exists) {
        await repository.registerFamilyMember(name, relation, patientId);
        emit(AuthFamilySuccess(patientId));
      } else {
        emit(AuthFailure("كود المريض غير صحيح. يرجى التأكد من الكود المكون من (PA-xxxx)"));
      }
    } catch (e) {
      emit(AuthFailure("حدث خطأ في الاتصال، يرجى المحاولة لاحقاً."));
    }
  }
}