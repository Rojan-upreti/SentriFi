package com.sentrif.sentrif

import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val settingsChannel = "com.sentrif/settings"
    private val wifiChannel = "com.sentrif/wifi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, settingsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openWifiSettings" -> {
                        startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, wifiChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWifiSignalInfo" -> result.success(getWifiSignalInfo())
                    else -> result.notImplemented()
                }
            }
    }

    private fun getWifiSignalInfo(): Map<String, Int?> {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val connectionInfo = wifiManager.connectionInfo

        return mapOf(
            "rssi" to connectionInfo.rssi,
            "frequency" to connectionInfo.frequency,
            "linkSpeed" to connectionInfo.linkSpeed
        )
    }
}
