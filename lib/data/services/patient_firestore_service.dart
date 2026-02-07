import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afya_id/data/models/patient_model.dart';

class PatientFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'patients';

  // CREATE - Ajouter un nouveau patient
  Future<void> createPatient(PatientModel patient) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(patient.id)
          .set(patient.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création du patient: $e');
    }
  }

  // READ - Récupérer un patient par ID
  Future<PatientModel?> getPatient(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return PatientModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du patient: $e');
    }
  }

  // READ ALL - Récupérer tous les patients
  Future<List<PatientModel>> getAllPatients() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => PatientModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des patients: $e');
    }
  }

  // STREAM - Stream de tous les patients (temps réel)
  Stream<List<PatientModel>> streamAllPatients() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientModel.fromFirestore(doc))
              .toList(),
        );
  }

  // STREAM - Stream d'un patient spécifique
  Stream<PatientModel?> streamPatient(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? PatientModel.fromFirestore(doc) : null);
  }

  // UPDATE - Mettre à jour un patient
  Future<void> updatePatient(PatientModel patient) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(patient.id)
          .update(patient.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du patient: $e');
    }
  }

  // DELETE - Supprimer un patient
  Future<void> deletePatient(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du patient: $e');
    }
  }

  // SEARCH - Rechercher des patients par nom
  Future<List<PatientModel>> searchPatientsByName(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => PatientModel.fromFirestore(doc))
          .where(
            (patient) =>
                patient.fullName.toLowerCase().contains(query.toLowerCase()) ||
                patient.id.contains(query),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de patients: $e');
    }
  }

  // FILTER - Filtrer par localisation
  Future<List<PatientModel>> getPatientsByLocation(String location) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('location', isEqualTo: location)
          .get();
      return snapshot.docs
          .map((doc) => PatientModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par localisation: $e');
    }
  }

  // UPDATE VITAL SIGNS - Mettre à jour les signes vitaux
  // Future<void> updateVitalSigns(
  //   String patientId,
  //   Map<String, dynamic> vitalSigns,
  // ) async {
  //   try {
  //     await updatePatient(patientId, {'latestVitalSigns': vitalSigns});
  //   } catch (e) {
  //     throw Exception('Erreur lors de la mise à jour des signes vitaux: $e');
  //   }
  // }
}
