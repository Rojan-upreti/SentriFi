import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/wifi_baseline_model.dart';
import '../utils/storage_keys.dart';

class WifiStorageService {
  Future<void> saveBaseline(WifiBaselineModel baseline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.wifiBaseline,
      jsonEncode(baseline.toJson()),
    );
  }

  Future<WifiBaselineModel?> loadBaseline() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.wifiBaseline);
    if (raw == null) return null;

    return WifiBaselineModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clearBaseline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.wifiBaseline);
  }
}
