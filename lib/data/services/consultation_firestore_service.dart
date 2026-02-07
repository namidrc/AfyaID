import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afya_id/data/models/consultation_log_model.dart';

class ConsultationFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'consultation_logs';

  // CREATE
  Future<void> createConsultationLog(ConsultationLogModel log) async {
    try {
      await _firestore.collection(_collection).doc(log.id).set(log.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création du log de consultation: $e');
    }
  }

  // READ
  Future<ConsultationLogModel?> getConsultationLog(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ConsultationLogModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du log: $e');
    }
  }

  // READ ALL
  Future<List<ConsultationLogModel>> getAllConsultationLogs() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ConsultationLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des logs: $e');
    }
  }

  // STREAM ALL
  Stream<List<ConsultationLogModel>> streamAllConsultationLogs() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConsultationLogModel.fromFirestore(doc))
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateConsultationLog(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du log: $e');
    }
  }

  // DELETE
  Future<void> deleteConsultationLog(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du log: $e');
    }
  }

  // FILTER - Par type d'accès
  Future<List<ConsultationLogModel>> getLogsByAccessType(
    String accessType,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('accessType', isEqualTo: accessType)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ConsultationLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par type d\'accès: $e');
    }
  }

  // STREAM - Par type d'accès
  Stream<List<ConsultationLogModel>> streamLogsByAccessType(String accessType) {
    return _firestore
        .collection(_collection)
        .where('accessType', isEqualTo: accessType)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConsultationLogModel.fromFirestore(doc))
              .toList(),
        );
  }

  // FILTER - Par patient
  Future<List<ConsultationLogModel>> getLogsByPatient(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ConsultationLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par patient: $e');
    }
  }

  // FILTER - Par date
  Future<List<ConsultationLogModel>> getLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ConsultationLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par date: $e');
    }
  }

  // PAGINATION - Récupérer avec limite
  Future<List<ConsultationLogModel>> getLogsWithLimit(int limit) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => ConsultationLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération paginée: $e');
    }
  }
}
