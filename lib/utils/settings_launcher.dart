import 'dart:io';

import 'package:flutter/services.dart';

class SettingsLauncher {
  static const _channel = MethodChannel('com.sentrif/settings');

  static Future<void> openWifiSettings() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod<void>('openWifiSettings');
      return;
    }

    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('openWifiSettings');
    }
  }
}
