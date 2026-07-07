import 'dart:io';

import '../models/router_ping_model.dart';

class RouterScanService {
  static const _pingCount = 10;

  Future<RouterPingModel> pingGateway(
    String gatewayIp, {
    int count = _pingCount,
  }) async {
    final trimmedGateway = gatewayIp.trim();
    if (trimmedGateway.isEmpty) {
      return _failedScan(
        gatewayIp: 'Unavailable',
        sentPackets: count,
        errorMessage: 'Gateway IP is unavailable.',
      );
    }

    final latencies = <int>[];

    for (var index = 0; index < count; index++) {
      final latency = await _pingOnce(trimmedGateway);
      if (latency != null) {
        latencies.add(latency);
      }
    }

    final errorMessage = latencies.isEmpty
        ? 'Router did not respond before the timeout.'
        : null;

    return RouterPingModel(
      gatewayIp: trimmedGateway,
      sentPackets: count,
      receivedPackets: latencies.length,
      latencies: latencies,
      averageLatency: calculateAverageLatency(latencies),
      minLatency: calculateMinLatency(latencies),
      maxLatency: calculateMaxLatency(latencies),
      jitter: calculateJitter(latencies),
      packetLossPercentage: calculatePacketLoss(count, latencies.length),
      scannedAt: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  double calculateAverageLatency(List<int> latencies) {
    if (latencies.isEmpty) return 0;
    return latencies.reduce((a, b) => a + b) / latencies.length;
  }

  int calculateMinLatency(List<int> latencies) {
    if (latencies.isEmpty) return 0;
    return latencies.reduce((a, b) => a < b ? a : b);
  }

  int calculateMaxLatency(List<int> latencies) {
    if (latencies.isEmpty) return 0;
    return latencies.reduce((a, b) => a > b ? a : b);
  }

  double calculateJitter(List<int> latencies) {
    if (latencies.length < 2) return 0;

    var totalDifference = 0;
    for (var index = 1; index < latencies.length; index++) {
      totalDifference += (latencies[index] - latencies[index - 1]).abs();
    }

    return totalDifference / (latencies.length - 1);
  }

  double calculatePacketLoss(int sentPackets, int receivedPackets) {
    if (sentPackets <= 0) return 100;
    final lostPackets = sentPackets - receivedPackets;
    return (lostPackets / sentPackets) * 100;
  }

  Future<int?> _pingOnce(String host) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await Process.run('ping', [
        '-c',
        '1',
        '-W',
        Platform.isIOS ? '1000' : '1',
        host,
      ]).timeout(const Duration(seconds: 2));

      stopwatch.stop();
      if (result.exitCode != 0) return null;

      final output = '${result.stdout} ${result.stderr}';
      final match = RegExp(r'time[=<](\d+(?:\.\d+)?)\s*ms').firstMatch(output);
      if (match != null) {
        return double.parse(match.group(1)!).round();
      }

      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      stopwatch.stop();
      return null;
    }
  }

  RouterPingModel _failedScan({
    required String gatewayIp,
    required int sentPackets,
    required String errorMessage,
  }) {
    return RouterPingModel(
      gatewayIp: gatewayIp,
      sentPackets: sentPackets,
      receivedPackets: 0,
      latencies: const [],
      averageLatency: 0,
      minLatency: 0,
      maxLatency: 0,
      jitter: 0,
      packetLossPercentage: 100,
      scannedAt: DateTime.now(),
      errorMessage: errorMessage,
    );
  }
}
