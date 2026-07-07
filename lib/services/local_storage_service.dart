import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/router_ping_model.dart';
import '../models/wifi_profile_model.dart';

class LocalStorageService {
  static const _savedWifiProfileKey = 'selected_wifi_profile';
  static const _savedRouterPingKey = 'selected_wifi_router_ping';

  Future<void> saveWifiProfile(
    WifiProfileModel profile,
    RouterPingModel ping,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedProfile = profile.copyWith(savedAt: DateTime.now());

    await prefs.setString(
      _savedWifiProfileKey,
      jsonEncode(savedProfile.toJson()),
    );
    await prefs.setString(_savedRouterPingKey, jsonEncode(ping.toJson()));
  }

  Future<WifiProfileModel?> getSavedWifiProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_savedWifiProfileKey);
    if (rawProfile == null) return null;

    try {
      return WifiProfileModel.fromJson(
        jsonDecode(rawProfile) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavedWifiProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedWifiProfileKey);
    await prefs.remove(_savedRouterPingKey);
  }
}
