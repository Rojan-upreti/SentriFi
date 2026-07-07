import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../models/ping_result_model.dart';
import '../models/wifi_baseline_model.dart';
import '../models/wifi_info_model.dart';
import '../utils/network_stats_util.dart';
import '../utils/permission_helper.dart';
import '../utils/ping_util.dart';
import 'wifi_storage_service.dart';

class WifiScanService {
  WifiScanService({
    Connectivity? connectivity,
    NetworkInfo? networkInfo,
    WifiStorageService? storageService,
  })  : _connectivity = connectivity ?? Connectivity(),
        _networkInfo = networkInfo ?? NetworkInfo(),
        _storageService = storageService ?? WifiStorageService();

  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;
  final WifiStorageService _storageService;

  Future<bool> requestPermissions() => PermissionHelper.requestWifiPermissions();

  Future<bool> checkWifiConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  Future<WifiInfoModel> getWifiInfo() async {
    final isConnected = await checkWifiConnection();
    if (!isConnected) {
      return WifiInfoModel.disconnected();
    }

    final ssid = _sanitize(await _networkInfo.getWifiName());
    final bssid = _sanitize(await _networkInfo.getWifiBSSID());
    final gatewayIp = _sanitize(await _networkInfo.getWifiGatewayIP());
    final localIp = _sanitize(await _networkInfo.getWifiIP());

    return WifiInfoModel(
      isConnected: true,
      ssid: ssid,
      bssid: bssid,
      gatewayIp: gatewayIp,
      localIp: localIp,
    );
  }

  Future<List<PingResultModel>> pingGateway(
    String gatewayIp, {
    int count = NetworkStatsUtil.baselinePingCount,
  }) async {
    final pings = <PingResultModel>[];

    for (var i = 0; i < count; i++) {
      final result = await PingUtil.pingHost(
        gatewayIp,
        sequence: i + 1,
      );
      pings.add(result);
    }

    return pings;
  }

  ({
    double averageLatencyMs,
    double minLatencyMs,
    double maxLatencyMs,
    double jitterMs,
    double packetLossPercent,
  }) calculateBaseline(List<PingResultModel> pings) {
    return NetworkStatsUtil.calculateBaseline(pings);
  }

  Future<WifiBaselineModel> saveSelectedWifi({
    required WifiInfoModel wifiInfo,
    required List<PingResultModel> pings,
  }) async {
    final baseline = NetworkStatsUtil.buildBaseline(
      wifiInfo: wifiInfo,
      pings: pings,
    );

    await _storageService.saveBaseline(baseline);
    return baseline;
  }

  Future<WifiBaselineModel?> loadSavedBaseline() {
    return _storageService.loadBaseline();
  }

  String? _sanitize(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed == '<unknown ssid>' ||
        trimmed == 'null' ||
        trimmed == '02:00:00:00:00:00') {
      return null;
    }

    return trimmed;
  }
}
