import 'package:sqflite/sqflite.dart';

import '../models/calibration_profile_model.dart';
import '../models/detection_alert_model.dart';
import '../models/wifi_signal_sample_model.dart';
import 'sentrif_database.dart';

class CalibrationRepository {
  CalibrationRepository({SentrifDatabase? database})
    : _database = database ?? SentrifDatabase.instance;

  final SentrifDatabase _database;

  Future<CalibrationProfileModel?> getActiveProfile() async {
    final db = await _database.database;
    final rows = await db.query(
      'calibration_profiles',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'last_calibrated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CalibrationProfileModel.fromMap(rows.first);
  }

  Future<CalibrationProfileModel> saveCalibration({
    required CalibrationProfileModel profile,
    required List<WifiSignalSampleModel> samples,
  }) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      await txn.update('calibration_profiles', {'is_active': 0});

      final profileId = await txn.insert(
        'calibration_profiles',
        profile.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final sample in samples) {
        await txn.insert(
          'wifi_signal_samples',
          sample.copyWith(profileId: profileId).toMap()..remove('id'),
        );
      }

      return profile.copyWith(id: profileId);
    });
  }

  Future<int> saveMonitoringSample(WifiSignalSampleModel sample) async {
    final db = await _database.database;
    return db.insert('wifi_signal_samples', sample.toMap()..remove('id'));
  }

  Future<int> saveAlert(DetectionAlertModel alert) async {
    final db = await _database.database;
    return db.insert('detection_alerts', alert.toMap()..remove('id'));
  }

  Future<DetectionAlertModel?> getLatestAlert(int profileId) async {
    final db = await _database.database;
    final rows = await db.query(
      'detection_alerts',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DetectionAlertModel.fromMap(rows.first);
  }

  Future<List<WifiSignalSampleModel>> getSamplesForProfile(
    int profileId, {
    String? phase,
    int limit = 120,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'wifi_signal_samples',
      where: phase == null ? 'profile_id = ?' : 'profile_id = ? AND phase = ?',
      whereArgs: phase == null ? [profileId] : [profileId, phase],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(WifiSignalSampleModel.fromMap).toList();
  }
}
