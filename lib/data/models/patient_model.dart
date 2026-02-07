import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afya_id/data/models/vital_signs_model.dart';

class PatientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String gender; // HOMME, FEMME
  final String location;
  final String imageUrl;
  final String bloodGroup; // A+, B-, etc.
  final String allergy;
  final DateTime dateOfBirth;
  final String nationalId;
  final List<String> chronicConditions;
  final VitalSignsModel? latestVitalSigns;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.location,
    required this.imageUrl,
    required this.bloodGroup,
    required this.allergy,
    required this.dateOfBirth,
    required this.nationalId,
    this.chronicConditions = const [],
    this.latestVitalSigns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'location': location,
      'imageUrl': imageUrl,
      'bloodGroup': bloodGroup,
      'allergy': allergy,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'nationalId': nationalId,
      'chronicConditions': chronicConditions,
      'latestVitalSigns': latestVitalSigns?.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      gender: data['gender'] ?? 'HOMME',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      bloodGroup: data['bloodGroup'] ?? 'O+',
      allergy: data['allergy'] ?? 'AUCUNE',
      dateOfBirth:
          (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nationalId: data['nationalId'] ?? '',
      chronicConditions: List<String>.from(data['chronicConditions'] ?? []),
      latestVitalSigns: data['latestVitalSigns'] != null
          ? VitalSignsModel.fromFirestore(data['latestVitalSigns'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PatientModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? gender,
    String? location,
    String? imageUrl,
    String? bloodGroup,
    String? allergy,
    DateTime? dateOfBirth,
    String? nationalId,
    List<String>? chronicConditions,
    VitalSignsModel? latestVitalSigns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergy: allergy ?? this.allergy,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      latestVitalSigns: latestVitalSigns ?? this.latestVitalSigns,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
