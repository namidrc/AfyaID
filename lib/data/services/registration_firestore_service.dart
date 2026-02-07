import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afya_id/data/models/registration_model.dart';

class RegistrationFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'registrations';

  // CREATE
  Future<void> createRegistration(RegistrationModel registration) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(registration.id)
          .set(registration.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'enregistrement: $e');
    }
  }

  // READ
  Future<RegistrationModel?> getRegistration(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return RegistrationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération de l\'enregistrement: $e',
      );
    }
  }

  // READ ALL
  Future<List<RegistrationModel>> getAllRegistrations() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RegistrationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des enregistrements: $e');
    }
  }

  // STREAM ALL
  Stream<List<RegistrationModel>> streamAllRegistrations() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RegistrationModel.fromFirestore(doc))
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateRegistration(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  // DELETE
  Future<void> deleteRegistration(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // UPDATE STEP - Mettre à jour l'étape actuelle
  Future<void> updateCurrentStep(String id, int step) async {
    try {
      await updateRegistration(id, {'currentStep': step});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'étape: $e');
    }
  }

  // UPDATE STATUS - Mettre à jour le statut
  Future<void> updateStatus(String id, String status) async {
    try {
      await updateRegistration(id, {'registrationStatus': status});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // COMPLETE REGISTRATION - Marquer comme complété
  Future<void> completeRegistration(String id) async {
    try {
      await updateRegistration(id, {
        'registrationStatus': 'COMPLETED',
        'currentStep': 4,
      });
    } catch (e) {
      throw Exception('Erreur lors de la finalisation: $e');
    }
  }

  // FILTER - Par statut
  Future<List<RegistrationModel>> getRegistrationsByStatus(
    String status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('registrationStatus', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RegistrationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par statut: $e');
    }
  }

  // STREAM - Par statut
  Stream<List<RegistrationModel>> streamRegistrationsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('registrationStatus', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RegistrationModel.fromFirestore(doc))
              .toList(),
        );
  }

  // UPDATE BIOMETRIC - Mettre à jour les données biométriques
  Future<void> updateBiometric(
    String id, {
    bool? facial,
    bool? fingerprint,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (facial != null) data['hasFacialBiometric'] = facial;
      if (fingerprint != null) data['hasFingerprintBiometric'] = fingerprint;

      await updateRegistration(id, data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour biométrique: $e');
    }
  }
}
