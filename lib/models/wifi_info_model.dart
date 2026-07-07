class WifiInfoModel {
  const WifiInfoModel({
    required this.isConnected,
    this.ssid,
    this.bssid,
    this.gatewayIp,
    this.localIp,
  });

  final bool isConnected;
  final String? ssid;
  final String? bssid;
  final String? gatewayIp;
  final String? localIp;

  WifiInfoModel copyWith({
    bool? isConnected,
    String? ssid,
    String? bssid,
    String? gatewayIp,
    String? localIp,
  }) {
    return WifiInfoModel(
      isConnected: isConnected ?? this.isConnected,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      localIp: localIp ?? this.localIp,
    );
  }

  Map<String, dynamic> toJson() => {
        'isConnected': isConnected,
        'ssid': ssid,
        'bssid': bssid,
        'gatewayIp': gatewayIp,
        'localIp': localIp,
      };

  factory WifiInfoModel.fromJson(Map<String, dynamic> json) {
    return WifiInfoModel(
      isConnected: json['isConnected'] as bool? ?? false,
      ssid: json['ssid'] as String?,
      bssid: json['bssid'] as String?,
      gatewayIp: json['gatewayIp'] as String?,
      localIp: json['localIp'] as String?,
    );
  }

  factory WifiInfoModel.disconnected() => const WifiInfoModel(isConnected: false);
}
