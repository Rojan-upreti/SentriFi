class WifiSignalSampleModel {
  const WifiSignalSampleModel({
    this.id,
    this.profileId,
    required this.phase,
    required this.timestamp,
    required this.isConnected,
    this.ssid,
    this.bssid,
    this.rssi,
    this.frequency,
    this.linkSpeed,
    this.gatewayIp,
    this.localIp,
    this.averageLatency,
    this.jitter,
    this.packetLossPercentage,
    this.sentPackets,
    this.receivedPackets,
    this.anomalyScore,
  });

  final int? id;
  final int? profileId;
  final String phase;
  final DateTime timestamp;
  final bool isConnected;
  final String? ssid;
  final String? bssid;
  final int? rssi;
  final int? frequency;
  final int? linkSpeed;
  final String? gatewayIp;
  final String? localIp;
  final double? averageLatency;
  final double? jitter;
  final double? packetLossPercentage;
  final int? sentPackets;
  final int? receivedPackets;
  final double? anomalyScore;

  WifiSignalSampleModel copyWith({
    int? id,
    int? profileId,
    String? phase,
    DateTime? timestamp,
    bool? isConnected,
    String? ssid,
    String? bssid,
    int? rssi,
    int? frequency,
    int? linkSpeed,
    String? gatewayIp,
    String? localIp,
    double? averageLatency,
    double? jitter,
    double? packetLossPercentage,
    int? sentPackets,
    int? receivedPackets,
    double? anomalyScore,
  }) {
    return WifiSignalSampleModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      phase: phase ?? this.phase,
      timestamp: timestamp ?? this.timestamp,
      isConnected: isConnected ?? this.isConnected,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      rssi: rssi ?? this.rssi,
      frequency: frequency ?? this.frequency,
      linkSpeed: linkSpeed ?? this.linkSpeed,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      localIp: localIp ?? this.localIp,
      averageLatency: averageLatency ?? this.averageLatency,
      jitter: jitter ?? this.jitter,
      packetLossPercentage: packetLossPercentage ?? this.packetLossPercentage,
      sentPackets: sentPackets ?? this.sentPackets,
      receivedPackets: receivedPackets ?? this.receivedPackets,
      anomalyScore: anomalyScore ?? this.anomalyScore,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'profile_id': profileId,
    'phase': phase,
    'timestamp': timestamp.toIso8601String(),
    'is_connected': isConnected ? 1 : 0,
    'ssid': ssid,
    'bssid': bssid,
    'rssi': rssi,
    'frequency': frequency,
    'link_speed': linkSpeed,
    'gateway_ip': gatewayIp,
    'local_ip': localIp,
    'average_latency': averageLatency,
    'jitter': jitter,
    'packet_loss_percentage': packetLossPercentage,
    'sent_packets': sentPackets,
    'received_packets': receivedPackets,
    'anomaly_score': anomalyScore,
  };

  factory WifiSignalSampleModel.fromMap(Map<String, Object?> map) {
    return WifiSignalSampleModel(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int?,
      phase: map['phase'] as String? ?? 'calibration',
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isConnected: (map['is_connected'] as int? ?? 0) == 1,
      ssid: map['ssid'] as String?,
      bssid: map['bssid'] as String?,
      rssi: map['rssi'] as int?,
      frequency: map['frequency'] as int?,
      linkSpeed: map['link_speed'] as int?,
      gatewayIp: map['gateway_ip'] as String?,
      localIp: map['local_ip'] as String?,
      averageLatency: (map['average_latency'] as num?)?.toDouble(),
      jitter: (map['jitter'] as num?)?.toDouble(),
      packetLossPercentage: (map['packet_loss_percentage'] as num?)?.toDouble(),
      sentPackets: map['sent_packets'] as int?,
      receivedPackets: map['received_packets'] as int?,
      anomalyScore: (map['anomaly_score'] as num?)?.toDouble(),
    );
  }
}
