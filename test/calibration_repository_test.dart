import 'package:flutter_test/flutter_test.dart';
import 'package:sentrif/models/calibration_profile_model.dart';
import 'package:sentrif/models/wifi_signal_sample_model.dart';
import 'package:sentrif/services/calibration_repository.dart';
import 'package:sentrif/services/sentrif_database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  test('saves and loads active calibration profile with samples', () async {
    final database = SentrifDatabase(databasePath: inMemoryDatabasePath);
    final repository = CalibrationRepository(database: database);

    final profile = CalibrationProfileModel(
      routerLocation: 'Office',
      createdAt: DateTime(2026),
      lastCalibratedAt: DateTime(2026, 7, 7),
      sampleCount: 1,
      ssid: 'SentriFi-Test',
      gatewayIp: '192.168.1.1',
      baselineLatency: 12,
      baselineJitter: 2,
      baselinePacketLoss: 0,
      isActive: true,
    );
    final sample = WifiSignalSampleModel(
      phase: 'calibration',
      timestamp: DateTime(2026),
      isConnected: true,
      ssid: 'SentriFi-Test',
      gatewayIp: '192.168.1.1',
      averageLatency: 12,
      jitter: 2,
      packetLossPercentage: 0,
    );

    final saved = await repository.saveCalibration(
      profile: profile,
      samples: [sample],
    );

    final active = await repository.getActiveProfile();
    final samples = await repository.getSamplesForProfile(
      saved.id!,
      phase: 'calibration',
    );

    expect(active?.routerLocation, 'Office');
    expect(active?.ssid, 'SentriFi-Test');
    expect(samples, hasLength(1));
    expect(samples.single.averageLatency, 12);

    await database.close();
  });
}
