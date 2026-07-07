class WifiBaselineModel {
  const WifiBaselineModel({
    required this.ssid,
    this.bssid,
    required this.gatewayIp,
    required this.localIp,
    required this.averageLatencyMs,
    required this.minLatencyMs,
    required this.maxLatencyMs,
    required this.jitterMs,
    required this.packetLossPercent,
    required this.setupTime,
  });

  final String ssid;
  final String? bssid;
  final String gatewayIp;
  final String localIp;
  final double averageLatencyMs;
  final double minLatencyMs;
  final double maxLatencyMs;
  final double jitterMs;
  final double packetLossPercent;
  final DateTime setupTime;

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'bssid': bssid,
    'gatewayIp': gatewayIp,
    'localIp': localIp,
    'averageLatencyMs': averageLatencyMs,
    'minLatencyMs': minLatencyMs,
    'maxLatencyMs': maxLatencyMs,
    'jitterMs': jitterMs,
    'packetLossPercent': packetLossPercent,
    'setupTime': setupTime.toIso8601String(),
  };

  factory WifiBaselineModel.fromJson(Map<String, dynamic> json) {
    return WifiBaselineModel(
      ssid: json['ssid'] as String,
      bssid: json['bssid'] as String?,
      gatewayIp: json['gatewayIp'] as String,
      localIp: json['localIp'] as String,
      averageLatencyMs: (json['averageLatencyMs'] as num).toDouble(),
      minLatencyMs: (json['minLatencyMs'] as num).toDouble(),
      maxLatencyMs: (json['maxLatencyMs'] as num).toDouble(),
      jitterMs: (json['jitterMs'] as num).toDouble(),
      packetLossPercent: (json['packetLossPercent'] as num).toDouble(),
      setupTime: DateTime.parse(json['setupTime'] as String),
    );
  }
}
