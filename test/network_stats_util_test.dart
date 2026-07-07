import 'package:flutter_test/flutter_test.dart';
import 'package:sentrif/models/ping_result_model.dart';
import 'package:sentrif/utils/network_stats_util.dart';

void main() {
  group('NetworkStatsUtil', () {
    test('calculateBaseline computes latency metrics and packet loss', () {
      final pings = [
        const PingResultModel(sequence: 1, success: true, latencyMs: 10),
        const PingResultModel(sequence: 2, success: true, latencyMs: 14),
        const PingResultModel(sequence: 3, success: true, latencyMs: 12),
        const PingResultModel(sequence: 4, success: false),
      ];

      final stats = NetworkStatsUtil.calculateBaseline(pings);

      expect(stats.averageLatencyMs, 12);
      expect(stats.minLatencyMs, 10);
      expect(stats.maxLatencyMs, 14);
      expect(stats.jitterMs, 3);
      expect(stats.packetLossPercent, 25);
    });

    test('calculateBaseline handles all failed pings', () {
      final pings = List.generate(
        10,
        (index) => PingResultModel(sequence: index + 1, success: false),
      );

      final stats = NetworkStatsUtil.calculateBaseline(pings);

      expect(stats.averageLatencyMs, 0);
      expect(stats.packetLossPercent, 100);
    });
  });
}
