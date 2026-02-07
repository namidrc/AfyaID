import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationModel {
  final String id;
  final String fullName;
  final String nationalId;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String allergies;
  final List<String> chronicConditions;
  final String location;
  final bool hasFacialBiometric;
  final bool hasFingerprintBiometric;
  final String registrationStatus; // PENDING, IN_PROGRESS, COMPLETED
  final int currentStep; // 1-4
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  RegistrationModel({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.allergies,
    this.chronicConditions = const [],
    required this.location,
    this.hasFacialBiometric = false,
    this.hasFingerprintBiometric = false,
    this.registrationStatus = 'PENDING',
    this.currentStep = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'nationalId': nationalId,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'location': location,
      'hasFacialBiometric': hasFacialBiometric,
      'hasFingerprintBiometric': hasFingerprintBiometric,
      'registrationStatus': registrationStatus,
      'currentStep': currentStep,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrl': imageUrl,
    };
  }

  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RegistrationModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      nationalId: data['nationalId'] ?? '',
      dateOfBirth:
          (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? 'Homme',
      bloodGroup: data['bloodGroup'] ?? 'O+',
      allergies: data['allergies'] ?? '',
      chronicConditions: List<String>.from(data['chronicConditions'] ?? []),
      location: data['location'] ?? '',
      hasFacialBiometric: data['hasFacialBiometric'] ?? false,
      hasFingerprintBiometric: data['hasFingerprintBiometric'] ?? false,
      registrationStatus: data['registrationStatus'] ?? 'PENDING',
      currentStep: data['currentStep'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
    );
  }

  RegistrationModel copyWith({
    String? id,
    String? fullName,
    String? nationalId,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? allergies,
    List<String>? chronicConditions,
    String? location,
    bool? hasFacialBiometric,
    bool? hasFingerprintBiometric,
    String? registrationStatus,
    int? currentStep,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      location: location ?? this.location,
      hasFacialBiometric: hasFacialBiometric ?? this.hasFacialBiometric,
      hasFingerprintBiometric:
          hasFingerprintBiometric ?? this.hasFingerprintBiometric,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      currentStep: currentStep ?? this.currentStep,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isCompleted => registrationStatus == 'COMPLETED';
  bool get hasBiometrics => hasFacialBiometric || hasFingerprintBiometric;
  double get progressPercentage => (currentStep / 4) * 100;
}
