import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendSOSAlert({required String patientID, required String name}) async {
    await _firestore.collection('alerts').add({
      'patientID': patientID,
      'name': name,
      'type': 'EMERGENCY',
      'message': 'نداء استغاثة عاجل من $name',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}