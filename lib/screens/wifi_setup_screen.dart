import 'dart:io';

import 'package:flutter/material.dart';

import '../models/ping_result_model.dart';
import '../models/wifi_info_model.dart';
import '../services/wifi_scan_service.dart';
import '../theme/app_theme.dart';
import '../utils/permission_helper.dart';
import '../utils/settings_launcher.dart';
import '../widgets/ping_results_card.dart';
import '../widgets/wifi_action_buttons.dart';
import '../widgets/wifi_info_card.dart';
import '../widgets/wifi_status_banner.dart';

class WifiSetupScreen extends StatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  State<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  final _wifiScanService = WifiScanService();

  WifiInfoModel _wifiInfo = WifiInfoModel.disconnected();
  List<PingResultModel> _pings = [];
  bool _isInitializing = true;
  bool _isScanning = false;
  bool _isPinging = false;
  bool _isSaving = false;
  bool _permissionsGranted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    _permissionsGranted = await _wifiScanService.requestPermissions();
    await _refreshWifiStatus();

    if (!mounted) return;
    setState(() => _isInitializing = false);
  }

  Future<void> _refreshWifiStatus() async {
    try {
      final wifiInfo = await _wifiScanService.getWifiInfo();
      if (!mounted) return;

      setState(() {
        _wifiInfo = wifiInfo;
        if (!wifiInfo.isConnected) {
          _pings = [];
        }
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to read Wi-Fi details: $error');
    }
  }

  Future<void> _scanWifi() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    _permissionsGranted = await _wifiScanService.requestPermissions();
    await _refreshWifiStatus();

    if (!mounted) return;
    setState(() => _isScanning = false);

    if (!_permissionsGranted) {
      _showMessage(
        'Location permission is required on Android to read the Wi-Fi name.',
        isError: true,
      );
    }
  }

  Future<void> _useThisWifi() async {
    if (!_wifiInfo.isConnected) {
      _showMessage('Connect to a Wi-Fi network first.', isError: true);
      return;
    }

    final gateway = _wifiInfo.gatewayIp;
    if (gateway == null || gateway.isEmpty) {
      _showMessage(
        'Gateway IP is unavailable for this network.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isPinging = true;
      _isSaving = true;
      _errorMessage = null;
      _pings = [];
    });

    try {
      final pings = await _wifiScanService.pingGateway(gateway);
      final baseline = await _wifiScanService.saveSelectedWifi(
        wifiInfo: _wifiInfo,
        pings: pings,
      );

      if (!mounted) return;

      setState(() {
        _pings = pings;
        _isPinging = false;
        _isSaving = false;
      });

      _showSuccessDialog(baseline.ssid);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPinging = false;
        _isSaving = false;
        _errorMessage = 'Failed to save Wi-Fi baseline: $error';
      });
    }
  }

  Future<void> _openWifiSettings() async {
    await SettingsLauncher.openWifiSettings();
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog(String ssid) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Baseline Saved'),
          ],
        ),
        content: const Text(
          'Wi-Fi baseline saved. SentriFi is ready to calibrate this room.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    _showMessage('Saved baseline for $ssid', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final stats = _pings.isEmpty
        ? null
        : _wifiScanService.calculateBaseline(_pings);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Wi-Fi Setup'),
        centerTitle: true,
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _scanWifi,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  WifiStatusBanner(isConnected: _wifiInfo.isConnected),
                  const SizedBox(height: 20),
                  if (Platform.isIOS) ...[
                    _PermissionNoteCard(
                      granted: _permissionsGranted,
                      message: PermissionHelper.iosLocalNetworkNote,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (Platform.isAndroid && !_permissionsGranted) ...[
                    const _PermissionNoteCard(
                      granted: false,
                      message:
                          'Location permission is required on Android to access the Wi-Fi SSID.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_wifiInfo.isConnected) ...[
                    WifiInfoCard(wifiInfo: _wifiInfo),
                    const SizedBox(height: 16),
                  ],
                  if (_wifiInfo.isConnected && (stats != null || _isPinging))
                    PingResultsCard(stats: stats, isLoading: _isPinging),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  WifiActionButtons(
                    isConnected: _wifiInfo.isConnected,
                    isScanning: _isScanning,
                    isSaving: _isSaving,
                    onScan: _scanWifi,
                    onUseWifi: _useThisWifi,
                    onOpenSettings: _openWifiSettings,
                  ),
                ],
              ),
            ),
    );
  }
}

class _PermissionNoteCard extends StatelessWidget {
  const _PermissionNoteCard({required this.granted, required this.message});

  final bool granted;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            granted ? Icons.verified_user_outlined : Icons.info_outline_rounded,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
