import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationLogModel {
  final String id;
  final String patientId;
  final String patientName;
  final String accessedBy; // Dr. Name or Inf. Name
  final String accessType; // URGENCE, STANDARD
  final String sessionId;
  final String description;
  final String? extra; // Additional info
  final DateTime timestamp;
  final String location;

  ConsultationLogModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.accessedBy,
    required this.accessType,
    required this.sessionId,
    required this.description,
    this.extra,
    required this.timestamp,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'accessedBy': accessedBy,
      'accessType': accessType,
      'sessionId': sessionId,
      'description': description,
      'extra': extra,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
    };
  }

  factory ConsultationLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConsultationLogModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      accessedBy: data['accessedBy'] ?? '',
      accessType: data['accessType'] ?? 'STANDARD',
      sessionId: data['sessionId'] ?? '',
      description: data['description'] ?? '',
      extra: data['extra'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
    );
  }

  ConsultationLogModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? accessedBy,
    String? accessType,
    String? sessionId,
    String? description,
    String? extra,
    DateTime? timestamp,
    String? location,
  }) {
    return ConsultationLogModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      accessedBy: accessedBy ?? this.accessedBy,
      accessType: accessType ?? this.accessType,
      sessionId: sessionId ?? this.sessionId,
      description: description ?? this.description,
      extra: extra ?? this.extra,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
    );
  }

  bool get isEmergency => accessType == 'URGENCE';
}
