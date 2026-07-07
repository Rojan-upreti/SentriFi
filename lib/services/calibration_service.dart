import '../models/calibration_profile_model.dart';
import '../models/wifi_signal_sample_model.dart';
import 'calibration_repository.dart';
import 'wifi_signal_sampler_service.dart';

class CalibrationService {
  CalibrationService({
    CalibrationRepository? repository,
    WifiSignalSamplerService? sampler,
  }) : _repository = repository ?? CalibrationRepository(),
       _sampler = sampler ?? WifiSignalSamplerService();

  final CalibrationRepository _repository;
  final WifiSignalSamplerService _sampler;

  Future<WifiSignalSampleModel> captureCalibrationSample() {
    return _sampler.captureSample(phase: 'calibration', pingCount: 3);
  }

  Future<CalibrationProfileModel> saveBaseline({
    required String routerLocation,
    required List<WifiSignalSampleModel> samples,
  }) {
    final connectedSamples = samples
        .where((sample) => sample.isConnected)
        .toList();
    final source = connectedSamples.isNotEmpty ? connectedSamples : samples;
    final now = DateTime.now();
    final profile = CalibrationProfileModel(
      routerLocation: routerLocation,
      createdAt: now,
      lastCalibratedAt: now,
      sampleCount: samples.length,
      ssid: _latestString(source, (sample) => sample.ssid),
      bssid: _latestString(source, (sample) => sample.bssid),
      gatewayIp: _latestString(source, (sample) => sample.gatewayIp),
      localIp: _latestString(source, (sample) => sample.localIp),
      baselineRssi: _averageInt(source, (sample) => sample.rssi),
      baselineFrequency: _averageInt(source, (sample) => sample.frequency),
      baselineLinkSpeed: _averageInt(source, (sample) => sample.linkSpeed),
      baselineLatency: _averageDouble(
        source,
        (sample) => sample.averageLatency,
      ),
      baselineJitter: _averageDouble(source, (sample) => sample.jitter),
      baselinePacketLoss: _averageDouble(
        source,
        (sample) => sample.packetLossPercentage,
      ),
      isActive: true,
    );

    return _repository.saveCalibration(profile: profile, samples: samples);
  }

  String? _latestString(
    List<WifiSignalSampleModel> samples,
    String? Function(WifiSignalSampleModel sample) read,
  ) {
    for (final sample in samples.reversed) {
      final value = read(sample);
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  double? _averageInt(
    List<WifiSignalSampleModel> samples,
    int? Function(WifiSignalSampleModel sample) read,
  ) {
    final values = samples.map(read).whereType<int>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _averageDouble(
    List<WifiSignalSampleModel> samples,
    double? Function(WifiSignalSampleModel sample) read,
  ) {
    final values = samples.map(read).whereType<double>().toList();
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}
