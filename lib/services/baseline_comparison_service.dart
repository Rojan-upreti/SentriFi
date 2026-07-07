import '../models/calibration_profile_model.dart';
import '../models/wifi_signal_sample_model.dart';

class BaselineComparisonResult {
  const BaselineComparisonResult({
    required this.anomalyScore,
    required this.isMovementSuspected,
  });

  final double anomalyScore;
  final bool isMovementSuspected;
}

class BaselineComparisonService {
  const BaselineComparisonService();

  BaselineComparisonResult compare({
    required CalibrationProfileModel profile,
    required WifiSignalSampleModel sample,
  }) {
    var score = 0.0;

    score += _ratioScore(
      current: sample.averageLatency,
      baseline: profile.baselineLatency,
      minimumDelta: 25,
      scale: 50,
    );
    score += _ratioScore(
      current: sample.jitter,
      baseline: profile.baselineJitter,
      minimumDelta: 12,
      scale: 30,
    );
    score += _ratioScore(
      current: sample.packetLossPercentage,
      baseline: profile.baselinePacketLoss,
      minimumDelta: 15,
      scale: 30,
    );

    if (sample.rssi != null && profile.baselineRssi != null) {
      final rssiDelta = (sample.rssi! - profile.baselineRssi!).abs();
      if (rssiDelta > 10) {
        score += (rssiDelta - 10) / 10;
      }
    }

    return BaselineComparisonResult(
      anomalyScore: score,
      isMovementSuspected: score >= 1,
    );
  }

  double _ratioScore({
    required double? current,
    required double baseline,
    required double minimumDelta,
    required double scale,
  }) {
    if (current == null) return 0;

    final delta = current - baseline;
    if (delta <= minimumDelta) return 0;

    return (delta - minimumDelta) / scale;
  }
}
