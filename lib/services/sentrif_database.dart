import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class SentrifDatabase {
  SentrifDatabase({this.databasePath});

  static final instance = SentrifDatabase();

  final String? databasePath;
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final resolvedPath =
        databasePath ??
        path.join(await getDatabasesPath(), 'sentrif_calibration.db');

    final opened = await openDatabase(
      resolvedPath,
      version: 1,
      onCreate: _create,
    );
    _database = opened;
    return opened;
  }

  Future<void> close() async {
    final existing = _database;
    if (existing == null) return;
    await existing.close();
    _database = null;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calibration_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        router_location TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_calibrated_at TEXT NOT NULL,
        sample_count INTEGER NOT NULL,
        ssid TEXT,
        bssid TEXT,
        gateway_ip TEXT,
        local_ip TEXT,
        baseline_rssi REAL,
        baseline_frequency REAL,
        baseline_link_speed REAL,
        baseline_latency REAL NOT NULL,
        baseline_jitter REAL NOT NULL,
        baseline_packet_loss REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE wifi_signal_samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER,
        phase TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_connected INTEGER NOT NULL,
        ssid TEXT,
        bssid TEXT,
        rssi INTEGER,
        frequency INTEGER,
        link_speed INTEGER,
        gateway_ip TEXT,
        local_ip TEXT,
        average_latency REAL,
        jitter REAL,
        packet_loss_percentage REAL,
        sent_packets INTEGER,
        received_packets INTEGER,
        anomaly_score REAL,
        FOREIGN KEY(profile_id) REFERENCES calibration_profiles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE detection_alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        router_location TEXT NOT NULL,
        message TEXT NOT NULL,
        status_message TEXT NOT NULL,
        anomaly_score REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(profile_id) REFERENCES calibration_profiles(id)
      )
    ''');
  }
}
