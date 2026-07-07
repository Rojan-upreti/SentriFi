import 'package:flutter/services.dart';

import '../models/wifi_signal_sample_model.dart';
import 'router_scan_service.dart';
import 'wifi_connection_service.dart';

class WifiSignalSamplerService {
  WifiSignalSamplerService({
    WifiConnectionService? connectionService,
    RouterScanService? routerScanService,
    MethodChannel? wifiChannel,
  }) : _connectionService = connectionService ?? WifiConnectionService(),
       _routerScanService = routerScanService ?? RouterScanService(),
       _wifiChannel = wifiChannel ?? const MethodChannel('com.sentrif/wifi');

  final WifiConnectionService _connectionService;
  final RouterScanService _routerScanService;
  final MethodChannel _wifiChannel;

  Future<WifiSignalSampleModel> captureSample({
    required String phase,
    int? profileId,
    int pingCount = 3,
  }) async {
    final profile = await _connectionService.getCurrentWifiProfile();
    final radio = await _readRadioMetrics();
    final gatewayIp = profile?.gatewayIp;
    final ping = gatewayIp == null || gatewayIp.trim().isEmpty
        ? null
        : await _routerScanService.pingGateway(gatewayIp, count: pingCount);

    return WifiSignalSampleModel(
      profileId: profileId,
      phase: phase,
      timestamp: DateTime.now(),
      isConnected: profile?.isConnected ?? false,
      ssid: profile?.ssid,
      bssid: profile?.bssid,
      rssi: radio.rssi,
      frequency: radio.frequency,
      linkSpeed: radio.linkSpeed,
      gatewayIp: profile?.gatewayIp,
      localIp: profile?.localIp,
      averageLatency: ping?.averageLatency,
      jitter: ping?.jitter,
      packetLossPercentage: ping?.packetLossPercentage,
      sentPackets: ping?.sentPackets,
      receivedPackets: ping?.receivedPackets,
    );
  }

  Future<({int? rssi, int? frequency, int? linkSpeed})>
  _readRadioMetrics() async {
    try {
      final result = await _wifiChannel.invokeMapMethod<String, Object?>(
        'getWifiSignalInfo',
      );
      return (
        rssi: _asInt(result?['rssi']),
        frequency: _asInt(result?['frequency']),
        linkSpeed: _asInt(result?['linkSpeed']),
      );
    } on PlatformException {
      return (rssi: null, frequency: null, linkSpeed: null);
    } on MissingPluginException {
      return (rssi: null, frequency: null, linkSpeed: null);
    }
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return null;
  }
}
