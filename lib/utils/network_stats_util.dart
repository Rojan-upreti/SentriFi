import '../models/ping_result_model.dart';
import '../models/wifi_baseline_model.dart';
import '../models/wifi_info_model.dart';

class NetworkStatsUtil {
  static const baselinePingCount = 10;

  static ({
    double averageLatencyMs,
    double minLatencyMs,
    double maxLatencyMs,
    double jitterMs,
    double packetLossPercent,
  })
  calculateBaseline(List<PingResultModel> pings) {
    if (pings.isEmpty) {
      return (
        averageLatencyMs: 0,
        minLatencyMs: 0,
        maxLatencyMs: 0,
        jitterMs: 0,
        packetLossPercent: 100,
      );
    }

    final successful = pings
        .where((ping) => ping.success && ping.latencyMs != null)
        .toList(growable: false);

    final packetLossPercent =
        ((pings.length - successful.length) / pings.length) * 100;

    if (successful.isEmpty) {
      return (
        averageLatencyMs: 0,
        minLatencyMs: 0,
        maxLatencyMs: 0,
        jitterMs: 0,
        packetLossPercent: packetLossPercent,
      );
    }

    final latencies = successful
        .map((ping) => ping.latencyMs!.toDouble())
        .toList();

    final averageLatencyMs =
        latencies.reduce((a, b) => a + b) / latencies.length;
    final minLatencyMs = latencies.reduce((a, b) => a < b ? a : b);
    final maxLatencyMs = latencies.reduce((a, b) => a > b ? a : b);

    var jitterMs = 0.0;
    if (latencies.length > 1) {
      var sumDiff = 0.0;
      for (var i = 1; i < latencies.length; i++) {
        sumDiff += (latencies[i] - latencies[i - 1]).abs();
      }
      jitterMs = sumDiff / (latencies.length - 1);
    }

    return (
      averageLatencyMs: averageLatencyMs,
      minLatencyMs: minLatencyMs,
      maxLatencyMs: maxLatencyMs,
      jitterMs: jitterMs,
      packetLossPercent: packetLossPercent,
    );
  }

  static WifiBaselineModel buildBaseline({
    required WifiInfoModel wifiInfo,
    required List<PingResultModel> pings,
    DateTime? setupTime,
  }) {
    final stats = calculateBaseline(pings);

    return WifiBaselineModel(
      ssid: wifiInfo.ssid ?? 'Unknown Network',
      bssid: wifiInfo.bssid,
      gatewayIp: wifiInfo.gatewayIp ?? 'Unknown',
      localIp: wifiInfo.localIp ?? 'Unknown',
      averageLatencyMs: stats.averageLatencyMs,
      minLatencyMs: stats.minLatencyMs,
      maxLatencyMs: stats.maxLatencyMs,
      jitterMs: stats.jitterMs,
      packetLossPercent: stats.packetLossPercent,
      setupTime: setupTime ?? DateTime.now(),
    );
  }
}
