import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../models/wifi_profile_model.dart';

class WifiConnectionService {
  WifiConnectionService({Connectivity? connectivity, NetworkInfo? networkInfo})
    : _connectivity = connectivity ?? Connectivity(),
      _networkInfo = networkInfo ?? NetworkInfo();

  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;

  Future<bool> isConnectedToWifi() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  Future<WifiProfileModel?> getCurrentWifiProfile() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final connectionType = _connectionTypeLabel(connectivityResults);

    if (!connectivityResults.contains(ConnectivityResult.wifi)) {
      return WifiProfileModel.disconnected(connectionType: connectionType);
    }

    return WifiProfileModel(
      isConnected: true,
      connectionType: connectionType,
      ssid: await _readNetworkValue(_networkInfo.getWifiName),
      bssid: await _readNetworkValue(_networkInfo.getWifiBSSID),
      gatewayIp: await _readNetworkValue(_networkInfo.getWifiGatewayIP),
      localIp: await _readNetworkValue(_networkInfo.getWifiIP),
      subnetMask: await _readNetworkValue(_networkInfo.getWifiSubmask),
      broadcastAddress: await _readNetworkValue(_networkInfo.getWifiBroadcast),
    );
  }

  Stream<bool> watchWifiConnectionStatus() {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.contains(ConnectivityResult.wifi);
    }).distinct();
  }

  String _connectionTypeLabel(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (results.contains(ConnectivityResult.mobile)) return 'Cellular';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    if (results.contains(ConnectivityResult.none)) return 'None';
    return 'Unavailable';
  }

  String? _sanitize(String? value) {
    if (value == null) return null;

    final trimmed = value.trim().replaceAll('"', '');
    if (trimmed.isEmpty ||
        trimmed == '<unknown ssid>' ||
        trimmed.toLowerCase() == 'null' ||
        trimmed == '02:00:00:00:00:00') {
      return null;
    }

    return trimmed;
  }

  Future<String?> _readNetworkValue(Future<String?> Function() read) async {
    try {
      return _sanitize(await read());
    } catch (_) {
      return null;
    }
  }
}
