import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afya_id/data/models/emergency_record_model.dart';

class EmergencyFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'emergency_records';

  // CREATE
  Future<void> createEmergencyRecord(EmergencyRecordModel record) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(record.id)
          .set(record.toJson());
    } catch (e) {
      throw Exception(
        'Erreur lors de la création de l\'enregistrement d\'urgence: $e',
      );
    }
  }

  // READ
  Future<EmergencyRecordModel?> getEmergencyRecord(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return EmergencyRecordModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de l\'enregistrement: $e',
      );
    }
  }

  // READ ALL
  Future<List<EmergencyRecordModel>> getAllEmergencyRecords() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => EmergencyRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des enregistrements: $e');
    }
  }

  // STREAM ALL
  Stream<List<EmergencyRecordModel>> streamAllEmergencyRecords() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyRecordModel.fromFirestore(doc))
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateEmergencyRecord(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  // DELETE
  Future<void> deleteEmergencyRecord(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // FILTER - Récupérer les urgences actives
  Future<List<EmergencyRecordModel>> getActiveEmergencies() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'ACTIF')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => EmergencyRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des urgences actives: $e',
      );
    }
  }

  // STREAM - Stream des urgences actives
  Stream<List<EmergencyRecordModel>> streamActiveEmergencies() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'ACTIF')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyRecordModel.fromFirestore(doc))
              .toList(),
        );
  }

  // STATISTICS - Compter les urgences actives
  Future<int> getActiveEmergenciesCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'ACTIF')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Erreur lors du comptage des urgences actives: $e');
    }
  }

  // STATISTICS - Compter les alertes critiques
  Future<int> getCriticalAlertsCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'ACTIF')
          .get();

      return snapshot.docs
          .map((doc) => EmergencyRecordModel.fromFirestore(doc))
          .where((record) => record.isCritical)
          .length;
    } catch (e) {
      throw Exception('Erreur lors du comptage des alertes critiques: $e');
    }
  }

  // UPDATE STATUS
  Future<void> updateStatus(String id, String newStatus) async {
    try {
      await updateEmergencyRecord(id, {'status': newStatus});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }
}
