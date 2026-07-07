import 'dart:async';

import '../models/calibration_profile_model.dart';
import '../models/detection_alert_model.dart';
import '../models/wifi_signal_sample_model.dart';
import 'baseline_comparison_service.dart';
import 'calibration_repository.dart';
import 'wifi_signal_sampler_service.dart';

class MonitoringResult {
  const MonitoringResult({
    required this.sample,
    required this.alert,
    required this.isMovementSuspected,
  });

  final WifiSignalSampleModel sample;
  final DetectionAlertModel? alert;
  final bool isMovementSuspected;
}

class MonitoringService {
  MonitoringService({
    CalibrationRepository? repository,
    WifiSignalSamplerService? sampler,
    BaselineComparisonService comparisonService =
        const BaselineComparisonService(),
  }) : _repository = repository ?? CalibrationRepository(),
       _sampler = sampler ?? WifiSignalSamplerService(),
       _comparisonService = comparisonService;

  final CalibrationRepository _repository;
  final WifiSignalSamplerService _sampler;
  final BaselineComparisonService _comparisonService;

  Future<MonitoringResult> captureMonitoringResult(
    CalibrationProfileModel profile,
  ) async {
    final profileId = profile.id;
    if (profileId == null) {
      throw StateError('Calibration profile must be saved before monitoring.');
    }

    final sample = await _sampler.captureSample(
      phase: 'monitoring',
      profileId: profileId,
      pingCount: 3,
    );
    final comparison = _comparisonService.compare(
      profile: profile,
      sample: sample,
    );
    final scoredSample = sample.copyWith(anomalyScore: comparison.anomalyScore);
    await _repository.saveMonitoringSample(scoredSample);

    DetectionAlertModel? alert;
    if (comparison.isMovementSuspected) {
      alert = DetectionAlertModel(
        profileId: profileId,
        routerLocation: profile.displayRouterLocation,
        message:
            'Possible movement detected near ${profile.displayRouterLocation}.',
        statusMessage: 'Suspected person roaming near the router area.',
        anomalyScore: comparison.anomalyScore,
        createdAt: DateTime.now(),
      );
      await _repository.saveAlert(alert);
    }

    return MonitoringResult(
      sample: scoredSample,
      alert: alert,
      isMovementSuspected: comparison.isMovementSuspected,
    );
  }

  Stream<MonitoringResult> watch(
    CalibrationProfileModel profile, {
    Duration interval = const Duration(seconds: 5),
  }) {
    late StreamController<MonitoringResult> controller;
    Timer? timer;

    Future<void> capture() async {
      try {
        controller.add(await captureMonitoringResult(profile));
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<MonitoringResult>(
      onListen: () {
        capture();
        timer = Timer.periodic(interval, (_) => capture());
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }
}
