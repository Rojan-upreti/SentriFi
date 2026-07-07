class RouterPingModel {
  const RouterPingModel({
    required this.gatewayIp,
    required this.sentPackets,
    required this.receivedPackets,
    required this.latencies,
    required this.averageLatency,
    required this.minLatency,
    required this.maxLatency,
    required this.jitter,
    required this.packetLossPercentage,
    required this.scannedAt,
    this.errorMessage,
  });

  final String gatewayIp;
  final int sentPackets;
  final int receivedPackets;
  final List<int> latencies;
  final double averageLatency;
  final int minLatency;
  final int maxLatency;
  final double jitter;
  final double packetLossPercentage;
  final DateTime scannedAt;
  final String? errorMessage;

  bool get hasSuccessfulPing => receivedPackets > 0;

  Map<String, dynamic> toJson() => {
    'gatewayIp': gatewayIp,
    'sentPackets': sentPackets,
    'receivedPackets': receivedPackets,
    'latencies': latencies,
    'averageLatency': averageLatency,
    'minLatency': minLatency,
    'maxLatency': maxLatency,
    'jitter': jitter,
    'packetLossPercentage': packetLossPercentage,
    'scannedAt': scannedAt.toIso8601String(),
    'errorMessage': errorMessage,
  };

  factory RouterPingModel.fromJson(Map<String, dynamic> json) {
    return RouterPingModel(
      gatewayIp: json['gatewayIp'] as String? ?? 'Unavailable',
      sentPackets: json['sentPackets'] as int? ?? 0,
      receivedPackets: json['receivedPackets'] as int? ?? 0,
      latencies: (json['latencies'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).round())
          .toList(),
      averageLatency: (json['averageLatency'] as num? ?? 0).toDouble(),
      minLatency: (json['minLatency'] as num? ?? 0).round(),
      maxLatency: (json['maxLatency'] as num? ?? 0).round(),
      jitter: (json['jitter'] as num? ?? 0).toDouble(),
      packetLossPercentage: (json['packetLossPercentage'] as num? ?? 100)
          .toDouble(),
      scannedAt:
          DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
