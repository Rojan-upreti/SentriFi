import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiPermissionService {
  Future<bool> requestWifiPermissions() async {
    if (Platform.isAndroid) {
      final location = await Permission.locationWhenInUse.request();
      return location.isGranted || location.isLimited;
    }

    if (Platform.isIOS) {
      final location = await Permission.locationWhenInUse.request();
      return location.isGranted || location.isLimited;
    }

    return true;
  }

  Future<bool> hasRequiredPermissions() async {
    if (Platform.isAndroid) {
      final location = await Permission.locationWhenInUse.status;
      return location.isGranted || location.isLimited;
    }

    if (Platform.isIOS) {
      final location = await Permission.locationWhenInUse.status;
      return location.isGranted || location.isLimited;
    }

    return true;
  }

  Future<void> openWifiSettings() {
    if (Platform.isIOS) {
      return AppSettings.openAppSettings();
    }

    return AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  Future<void> openAppSettingsPage() {
    return AppSettings.openAppSettings();
  }
}
