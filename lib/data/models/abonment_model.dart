class AbonmentModel {
  final String? id;
  String? recieverID;
  DateTime? starDate;
  DateTime? endDate;
  DateTime? dateCreated;
  String? activatedByID;
  String? reason;
  bool? isBonus;

  AbonmentModel({
    required this.id,
    this.recieverID,
    this.starDate,
    this.endDate,
    this.dateCreated,
    this.activatedByID,
    this.reason,
    this.isBonus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recieverID': recieverID,
      'starDate': starDate,
      'endDate': endDate,
      'dateCreated': dateCreated,
      'activatedByID': activatedByID,
      'reason': reason,
      'isBonus': isBonus,
    };
  }

  static AbonmentModel fromData(Map<String, dynamic> data) {
    // Robust date parsing helper function
    DateTime? parseDate(dynamic value) {
      try {
        if (value is DateTime) return value;
        if (value is String) return DateTime.tryParse(value);
        if (value != null && value.toDate is Function) return value.toDate();
      } catch (_) {}
      return null;
    }

    return AbonmentModel(
      id: data['id'] ?? '',
      recieverID: data['recieverID'] ?? '',
      starDate: parseDate(data['starDate']),
      endDate: parseDate(data['endDate']),
      dateCreated: parseDate(data['dateCreated']) ?? DateTime.now(),
      activatedByID: data['activatedByID'] ?? '',
      reason: data['reason'] ?? '',
      isBonus: data['isBonus'] ?? false,
    );
  }

  AbonmentModel copyWith({
    String? id,
    String? recieverID,
    DateTime? starDate,
    DateTime? endDate,
    DateTime? dateCreated,
    String? activatedByID,
    String? reason,
    bool? isBonus,
  }) => AbonmentModel(
    id: id ?? this.id,
    recieverID: recieverID ?? this.recieverID,
    starDate: starDate ?? this.starDate,
    endDate: endDate ?? this.endDate,
    dateCreated: dateCreated ?? this.dateCreated,
    activatedByID: activatedByID ?? this.activatedByID,
    reason: reason ?? this.reason,
    isBonus: isBonus ?? this.isBonus,
  );

  /// Vérifie si l'abonnement est actuellement actif
  bool get isActive {
    final now = DateTime.now();
    return starDate != null &&
        endDate != null &&
        now.isAfter(starDate!) &&
        now.isBefore(endDate!);
  }

  /// Calcule la durée totale de l'abonnement
  Duration? get duration {
    if (starDate == null || endDate == null) return null;
    return endDate!.difference(starDate!);
  }
}
