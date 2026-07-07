class DetectionAlertModel {
  const DetectionAlertModel({
    this.id,
    required this.profileId,
    required this.routerLocation,
    required this.message,
    required this.statusMessage,
    required this.anomalyScore,
    required this.createdAt,
  });

  final int? id;
  final int profileId;
  final String routerLocation;
  final String message;
  final String statusMessage;
  final double anomalyScore;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'profile_id': profileId,
    'router_location': routerLocation,
    'message': message,
    'status_message': statusMessage,
    'anomaly_score': anomalyScore,
    'created_at': createdAt.toIso8601String(),
  };

  factory DetectionAlertModel.fromMap(Map<String, Object?> map) {
    return DetectionAlertModel(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int? ?? 0,
      routerLocation: map['router_location'] as String? ?? 'Router Area',
      message: map['message'] as String? ?? 'Possible movement detected.',
      statusMessage:
          map['status_message'] as String? ??
          'Suspected person roaming near the router area.',
      anomalyScore: (map['anomaly_score'] as num? ?? 0).toDouble(),
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
