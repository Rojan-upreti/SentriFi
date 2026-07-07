import 'package:flutter_test/flutter_test.dart';
import 'package:sentrif/models/calibration_profile_model.dart';
import 'package:sentrif/models/wifi_signal_sample_model.dart';
import 'package:sentrif/services/baseline_comparison_service.dart';

void main() {
  group('BaselineComparisonService', () {
    final profile = CalibrationProfileModel(
      routerLocation: 'Living Room',
      createdAt: DateTime(2026),
      lastCalibratedAt: DateTime(2026),
      sampleCount: 12,
      baselineRssi: -48,
      baselineLatency: 15,
      baselineJitter: 4,
      baselinePacketLoss: 0,
      isActive: true,
    );

    test('does not flag normal signal drift', () {
      final result = const BaselineComparisonService().compare(
        profile: profile,
        sample: WifiSignalSampleModel(
          phase: 'monitoring',
          timestamp: DateTime(2026),
          isConnected: true,
          rssi: -52,
          averageLatency: 25,
          jitter: 8,
          packetLossPercentage: 2,
        ),
      );

      expect(result.isMovementSuspected, isFalse);
      expect(result.anomalyScore, 0);
    });

    test('flags unusual fluctuation against baseline', () {
      final result = const BaselineComparisonService().compare(
        profile: profile,
        sample: WifiSignalSampleModel(
          phase: 'monitoring',
          timestamp: DateTime(2026),
          isConnected: true,
          rssi: -70,
          averageLatency: 110,
          jitter: 42,
          packetLossPercentage: 40,
        ),
      );

      expect(result.isMovementSuspected, isTrue);
      expect(result.anomalyScore, greaterThanOrEqualTo(1));
    });
  });
}
