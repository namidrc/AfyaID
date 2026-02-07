import 'package:cloud_firestore/cloud_firestore.dart';

class VitalSignsModel {
  final int heartRate; // FC (BPM)
  final int oxygenSaturation; // SpO2 (%)
  final String bloodPressure; // e.g., "120/80"
  final DateTime timestamp;

  VitalSignsModel({
    required this.heartRate,
    required this.oxygenSaturation,
    required this.bloodPressure,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'oxygenSaturation': oxygenSaturation,
      'bloodPressure': bloodPressure,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory VitalSignsModel.fromFirestore(Map<String, dynamic> data) {
    return VitalSignsModel(
      heartRate: data['heartRate'] ?? 0,
      oxygenSaturation: data['oxygenSaturation'] ?? 0,
      bloodPressure: data['bloodPressure'] ?? '0/0',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  VitalSignsModel copyWith({
    int? heartRate,
    int? oxygenSaturation,
    String? bloodPressure,
    DateTime? timestamp,
  }) {
    return VitalSignsModel(
      heartRate: heartRate ?? this.heartRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Vérifie si les signes vitaux sont dans la plage normale
  bool get isNormal {
    return heartRate >= 60 &&
        heartRate <= 100 &&
        oxygenSaturation >= 95 &&
        oxygenSaturation <= 100;
  }

  /// Retourne le statut des signes vitaux
  String get status {
    if (isNormal) return 'NORMALE';
    if (heartRate > 100 || oxygenSaturation < 90) return 'CRITIQUE';
    return 'ATTENTION';
  }
}
