import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  void enableOfflineMode() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Vitals Streams
  Stream<DatabaseEvent> getVitalsStream() {
    return _database.ref('CurrentVitals').onValue;
  }

  Future<DataSnapshot> getInitialVitals() {
    return _database.ref("CurrentVitals").get();
  }

  Future<void> saveVitalToHistory(String patientID, String type, String value) async {
    await _firestore
        .collection('patients')
        .doc(patientID)
        .collection('vitals_history')
        .add({
      'type': type,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _database.ref("VitalsHistory").push().set({
      'type': type,
      'value': value,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getVitalsHistoryStream() {
    return _database.ref("VitalsHistory").limitToLast(50).onValue;
  }

  // Patient & Alerts Streams
  Stream<QuerySnapshot> getPatientAlertsStream(String patientId, {int? queryLimit}) {
    var query = _firestore
        .collection('alerts')
        .where('patientID', isEqualTo: patientId.trim())
        .orderBy('timestamp', descending: true);

    if (queryLimit != null) {
      query = query.limit(queryLimit);
    }

    return query.snapshots();
  }
  Stream<DocumentSnapshot> getPatientDataStream(String patientId) {
    return _firestore.collection('patients').doc(patientId.trim()).snapshots();
  }
}