class WifiProfileModel {
  const WifiProfileModel({
    required this.isConnected,
    required this.connectionType,
    this.ssid,
    this.bssid,
    this.gatewayIp,
    this.localIp,
    this.subnetMask,
    this.broadcastAddress,
    this.savedAt,
  });

  final bool isConnected;
  final String connectionType;
  final String? ssid;
  final String? bssid;
  final String? gatewayIp;
  final String? localIp;
  final String? subnetMask;
  final String? broadcastAddress;
  final DateTime? savedAt;

  String get displaySsid => _display(ssid);
  String get displayBssid => _display(bssid);
  String get displayGatewayIp => _display(gatewayIp);
  String get displayLocalIp => _display(localIp);
  String get displaySubnetMask => _display(subnetMask);
  String get displayBroadcastAddress => _display(broadcastAddress);

  WifiProfileModel copyWith({
    bool? isConnected,
    String? connectionType,
    String? ssid,
    String? bssid,
    String? gatewayIp,
    String? localIp,
    String? subnetMask,
    String? broadcastAddress,
    DateTime? savedAt,
  }) {
    return WifiProfileModel(
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      localIp: localIp ?? this.localIp,
      subnetMask: subnetMask ?? this.subnetMask,
      broadcastAddress: broadcastAddress ?? this.broadcastAddress,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'isConnected': isConnected,
    'connectionType': connectionType,
    'ssid': ssid,
    'bssid': bssid,
    'gatewayIp': gatewayIp,
    'localIp': localIp,
    'subnetMask': subnetMask,
    'broadcastAddress': broadcastAddress,
    'savedAt': savedAt?.toIso8601String(),
  };

  factory WifiProfileModel.fromJson(Map<String, dynamic> json) {
    return WifiProfileModel(
      isConnected: json['isConnected'] as bool? ?? false,
      connectionType: json['connectionType'] as String? ?? 'Unavailable',
      ssid: json['ssid'] as String?,
      bssid: json['bssid'] as String?,
      gatewayIp: json['gatewayIp'] as String?,
      localIp: json['localIp'] as String?,
      subnetMask: json['subnetMask'] as String?,
      broadcastAddress: json['broadcastAddress'] as String?,
      savedAt: json['savedAt'] == null
          ? null
          : DateTime.tryParse(json['savedAt'] as String),
    );
  }

  factory WifiProfileModel.disconnected({String connectionType = 'None'}) {
    return WifiProfileModel(isConnected: false, connectionType: connectionType);
  }

  static String _display(String? value) {
    if (value == null || value.trim().isEmpty) return 'Unavailable';
    return value;
  }
}
