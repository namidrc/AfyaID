import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRecordModel {
  final String id;
  final String patientId;
  final String patientName;
  final String emergencyType; // TRAUMA, CARDIAC, RESPIRATORY, etc.
  final String status; // ACTIF, RÉSOLU, EN_COURS
  final String location;
  final String description;
  final DateTime timestamp;
  final String? assignedDoctorId;
  final String? assignedDoctorName;

  EmergencyRecordModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.emergencyType,
    required this.status,
    required this.location,
    required this.description,
    required this.timestamp,
    this.assignedDoctorId,
    this.assignedDoctorName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'emergencyType': emergencyType,
      'status': status,
      'location': location,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'assignedDoctorId': assignedDoctorId,
      'assignedDoctorName': assignedDoctorName,
    };
  }

  factory EmergencyRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyRecordModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      emergencyType: data['emergencyType'] ?? 'GENERAL',
      status: data['status'] ?? 'ACTIF',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedDoctorId: data['assignedDoctorId'],
      assignedDoctorName: data['assignedDoctorName'],
    );
  }

  EmergencyRecordModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? emergencyType,
    String? status,
    String? location,
    String? description,
    DateTime? timestamp,
    String? assignedDoctorId,
    String? assignedDoctorName,
  }) {
    return EmergencyRecordModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      emergencyType: emergencyType ?? this.emergencyType,
      status: status ?? this.status,
      location: location ?? this.location,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      assignedDoctorName: assignedDoctorName ?? this.assignedDoctorName,
    );
  }

  bool get isActive => status == 'ACTIF';
  bool get isCritical =>
      emergencyType == 'CARDIAC' || emergencyType == 'TRAUMA';
}
