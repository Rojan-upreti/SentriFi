class CalibrationProfileModel {
  const CalibrationProfileModel({
    this.id,
    required this.routerLocation,
    required this.createdAt,
    required this.lastCalibratedAt,
    required this.sampleCount,
    this.ssid,
    this.bssid,
    this.gatewayIp,
    this.localIp,
    this.baselineRssi,
    this.baselineFrequency,
    this.baselineLinkSpeed,
    required this.baselineLatency,
    required this.baselineJitter,
    required this.baselinePacketLoss,
    required this.isActive,
  });

  final int? id;
  final String routerLocation;
  final DateTime createdAt;
  final DateTime lastCalibratedAt;
  final int sampleCount;
  final String? ssid;
  final String? bssid;
  final String? gatewayIp;
  final String? localIp;
  final double? baselineRssi;
  final double? baselineFrequency;
  final double? baselineLinkSpeed;
  final double baselineLatency;
  final double baselineJitter;
  final double baselinePacketLoss;
  final bool isActive;

  String get displaySsid => _display(ssid);
  String get displayRouterLocation =>
      routerLocation.trim().isEmpty ? 'Router Area' : routerLocation.trim();

  CalibrationProfileModel copyWith({
    int? id,
    String? routerLocation,
    DateTime? createdAt,
    DateTime? lastCalibratedAt,
    int? sampleCount,
    String? ssid,
    String? bssid,
    String? gatewayIp,
    String? localIp,
    double? baselineRssi,
    double? baselineFrequency,
    double? baselineLinkSpeed,
    double? baselineLatency,
    double? baselineJitter,
    double? baselinePacketLoss,
    bool? isActive,
  }) {
    return CalibrationProfileModel(
      id: id ?? this.id,
      routerLocation: routerLocation ?? this.routerLocation,
      createdAt: createdAt ?? this.createdAt,
      lastCalibratedAt: lastCalibratedAt ?? this.lastCalibratedAt,
      sampleCount: sampleCount ?? this.sampleCount,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      localIp: localIp ?? this.localIp,
      baselineRssi: baselineRssi ?? this.baselineRssi,
      baselineFrequency: baselineFrequency ?? this.baselineFrequency,
      baselineLinkSpeed: baselineLinkSpeed ?? this.baselineLinkSpeed,
      baselineLatency: baselineLatency ?? this.baselineLatency,
      baselineJitter: baselineJitter ?? this.baselineJitter,
      baselinePacketLoss: baselinePacketLoss ?? this.baselinePacketLoss,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'router_location': routerLocation,
    'created_at': createdAt.toIso8601String(),
    'last_calibrated_at': lastCalibratedAt.toIso8601String(),
    'sample_count': sampleCount,
    'ssid': ssid,
    'bssid': bssid,
    'gateway_ip': gatewayIp,
    'local_ip': localIp,
    'baseline_rssi': baselineRssi,
    'baseline_frequency': baselineFrequency,
    'baseline_link_speed': baselineLinkSpeed,
    'baseline_latency': baselineLatency,
    'baseline_jitter': baselineJitter,
    'baseline_packet_loss': baselinePacketLoss,
    'is_active': isActive ? 1 : 0,
  };

  factory CalibrationProfileModel.fromMap(Map<String, Object?> map) {
    return CalibrationProfileModel(
      id: map['id'] as int?,
      routerLocation: map['router_location'] as String? ?? 'Router Area',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      lastCalibratedAt:
          DateTime.tryParse(map['last_calibrated_at'] as String? ?? '') ??
          DateTime.now(),
      sampleCount: map['sample_count'] as int? ?? 0,
      ssid: map['ssid'] as String?,
      bssid: map['bssid'] as String?,
      gatewayIp: map['gateway_ip'] as String?,
      localIp: map['local_ip'] as String?,
      baselineRssi: (map['baseline_rssi'] as num?)?.toDouble(),
      baselineFrequency: (map['baseline_frequency'] as num?)?.toDouble(),
      baselineLinkSpeed: (map['baseline_link_speed'] as num?)?.toDouble(),
      baselineLatency: (map['baseline_latency'] as num? ?? 0).toDouble(),
      baselineJitter: (map['baseline_jitter'] as num? ?? 0).toDouble(),
      baselinePacketLoss: (map['baseline_packet_loss'] as num? ?? 0).toDouble(),
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  static String _display(String? value) {
    if (value == null || value.trim().isEmpty) return 'Unavailable';
    return value;
  }
}
