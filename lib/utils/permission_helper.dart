import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static const iosLocalNetworkNote =
      'On iOS, allow Local Network access when prompted so SentriFi can read Wi-Fi details.';

  static Future<bool> requestWifiPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.locationWhenInUse,
        Permission.nearbyWifiDevices,
      ].request();

      final locationGranted =
          statuses[Permission.locationWhenInUse]?.isGranted ?? false;
      final nearbyGranted =
          statuses[Permission.nearbyWifiDevices]?.isGranted ?? true;

      return locationGranted && nearbyGranted;
    }

    if (Platform.isIOS) {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted || status.isLimited;
    }

    return true;
  }

  static Future<bool> hasWifiPermissions() async {
    if (Platform.isAndroid) {
      final locationGranted = await Permission.locationWhenInUse.isGranted;
      final nearbyGranted = await Permission.nearbyWifiDevices.isGranted;
      return locationGranted && nearbyGranted;
    }

    if (Platform.isIOS) {
      final status = await Permission.locationWhenInUse.status;
      return status.isGranted || status.isLimited;
    }

    return true;
  }
}
