import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/calibration_profile_model.dart';
import '../models/detection_alert_model.dart';
import '../models/wifi_signal_sample_model.dart';
import '../services/calibration_repository.dart';
import '../services/monitoring_service.dart';

class HomeMonitoringController extends ChangeNotifier {
  HomeMonitoringController({
    CalibrationRepository? repository,
    MonitoringService? monitoringService,
  }) : _repository = repository ?? CalibrationRepository(),
       _monitoringService = monitoringService ?? MonitoringService();

  final CalibrationRepository _repository;
  final MonitoringService _monitoringService;

  StreamSubscription<MonitoringResult>? _monitoringSubscription;

  CalibrationProfileModel? profile;
  DetectionAlertModel? latestAlert;
  WifiSignalSampleModel? latestSample;
  bool isLoading = true;
  bool isArmed = false;
  bool isMovementSuspected = false;
  String detectionStatus = 'Disarmed';

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    profile = await _repository.getActiveProfile();
    final profileId = profile?.id;
    latestAlert = profileId == null
        ? null
        : await _repository.getLatestAlert(profileId);
    isLoading = false;
    detectionStatus = profile == null ? 'Calibration required' : 'Ready to arm';
    notifyListeners();
  }

  void arm() {
    final activeProfile = profile;
    if (activeProfile == null || isArmed) return;

    isArmed = true;
    isMovementSuspected = false;
    detectionStatus = 'Monitoring Wi-Fi signal';
    notifyListeners();

    _monitoringSubscription = _monitoringService
        .watch(activeProfile)
        .listen(
          (result) {
            latestSample = result.sample;
            isMovementSuspected = result.isMovementSuspected;
            if (result.alert != null) {
              latestAlert = result.alert;
              detectionStatus = result.alert!.statusMessage;
            } else {
              detectionStatus = 'No unusual movement detected';
            }
            notifyListeners();
          },
          onError: (_) {
            detectionStatus = 'Monitoring paused. Check Wi-Fi connection.';
            notifyListeners();
          },
        );
  }

  Future<void> disarm() async {
    await _monitoringSubscription?.cancel();
    _monitoringSubscription = null;
    isArmed = false;
    isMovementSuspected = false;
    detectionStatus = 'Disarmed';
    notifyListeners();
  }

  @override
  void dispose() {
    _monitoringSubscription?.cancel();
    super.dispose();
  }
}
