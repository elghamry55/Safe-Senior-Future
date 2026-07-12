import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // فحص حالة تسجيل الدخول السابقة
  Future<Map<String, dynamic>?> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      return {
        'role': prefs.getString('userRole') ?? 'patient', // 'patient' أو 'family'
        'patientID': prefs.getString('patientID'),
        'patientName': prefs.getString('patientName'),
      };
    }
    return null;
  }

  // تسجيل دخول مريض برقم موجود
  Future<Map<String, dynamic>?> loginPatient(String patientID) async {
    var doc = await _firestore.collection('patients').doc(patientID).get();

    if (doc.exists) {
      final prefs = await SharedPreferences.getInstance();
      String name = doc.data()?['name'] ?? 'مريض';

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userRole', 'patient');
      await prefs.setString('patientID', patientID);
      await prefs.setString('patientName', name);

      return {'patientID': patientID, 'patientName': name};
    }
    return null; // الرقم غير موجود
  }

  // تسجيل مريض جديد
  Future<String> registerPatient(String name, String age, String diseases) async {
    String patientID = "PA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    await _firestore.collection('patients').doc(patientID).set({
      'patientID': patientID,
      'name': name,
      'age': age,
      'chronicDiseases': diseases,
      'status': 'stable',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', 'patient');
    await prefs.setString('patientID', patientID);
    await prefs.setString('patientName', name);

    return patientID;
  }

  // التأكد من وجود كود المريض (للعائلة)
  Future<bool> checkPatientExists(String patientId) async {
    final doc = await _firestore.collection('patients').doc(patientId).get();
    return doc.exists;
  }

  // تسجيل فرد من العائلة
  Future<void> registerFamilyMember(String name, String relation, String patientId) async {
    await _firestore.collection('family_members').add({
      'name': name,
      'relation': relation,
      'linkedPatientId': patientId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', 'family');
    await prefs.setString('patientID', patientId);
  }
}