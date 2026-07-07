import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/router_ping_model.dart';
import '../models/wifi_profile_model.dart';
import '../services/local_storage_service.dart';
import '../services/router_scan_service.dart';
import '../services/wifi_connection_service.dart';
import '../services/wifi_permission_service.dart';
import '../widgets/permission_card.dart';
import '../widgets/router_scan_card.dart';
import '../widgets/wifi_status_card.dart';
import 'router_location_screen.dart';

const _creamBackground = Color(0xFFF7F2EA);
const _appleInk = Color(0xFF1D1D1F);
const _secondaryText = Color(0xFF6E6E73);

class WifiConnectScreen extends StatefulWidget {
  const WifiConnectScreen({super.key});

  @override
  State<WifiConnectScreen> createState() => _WifiConnectScreenState();
}

class _WifiConnectScreenState extends State<WifiConnectScreen>
    with WidgetsBindingObserver {
  final _permissionService = WifiPermissionService();
  final _connectionService = WifiConnectionService();
  final _routerScanService = RouterScanService();
  final _storageService = LocalStorageService();

  StreamSubscription<bool>? _connectionSubscription;

  WifiProfileModel? _profile;
  RouterPingModel? _ping;
  bool _hasPermissions = false;
  bool _isChecking = true;
  bool _isRequestingPermissions = false;
  bool _isScanning = false;
  bool _isSaving = false;
  String _statusMessage = 'Permission Required';
  String? _lastAutoScannedNetworkKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    _connectionSubscription = _connectionService
        .watchWifiConnectionStatus()
        .listen((_) {
          if (!mounted || !_hasPermissions) return;
          _refreshWifiStatus();
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_hasPermissions) return;
    _refreshWifiStatus();
  }

  Future<void> _bootstrap() async {
    setState(() => _isChecking = true);
    final hasPermissions = await _permissionService.hasRequiredPermissions();
    if (!mounted) return;

    setState(() {
      _hasPermissions = hasPermissions;
      _statusMessage = hasPermissions
          ? 'No Wi-Fi Connected'
          : 'Permission Required';
    });

    if (hasPermissions) {
      await _refreshWifiStatus();
    } else {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isRequestingPermissions = true);
    final granted = await _permissionService.requestWifiPermissions();
    if (!mounted) return;

    setState(() {
      _isRequestingPermissions = false;
      _hasPermissions = granted;
      _statusMessage = granted ? 'No Wi-Fi Connected' : 'Permission Required';
    });

    if (granted) {
      await _refreshWifiStatus();
    } else {
      _showMessage('Permission denied. You can enable access in Settings.');
    }
  }

  Future<void> _refreshWifiStatus() async {
    setState(() {
      _isChecking = true;
    });

    final profile = await _connectionService.getCurrentWifiProfile();
    if (!mounted) return;

    final isConnected = profile?.isConnected ?? false;
    final networkKey = _networkKey(profile);
    setState(() {
      _profile = profile;
      _isChecking = false;
      _statusMessage = isConnected ? 'Wi-Fi Connected' : 'No Wi-Fi Connected';
      if (!isConnected) {
        _ping = null;
        _lastAutoScannedNetworkKey = null;
      } else if (networkKey != _lastAutoScannedNetworkKey) {
        _ping = null;
      }
    });

    if (isConnected) {
      await _autoScanConnectedRouter(profile);
    }
  }

  Future<void> _openWifiSettings() async {
    await _permissionService.openWifiSettings();
    _refreshWifiStatusAfterSettings();
  }

  Future<void> _openAppSettings() async {
    await _permissionService.openAppSettingsPage();
  }

  Future<void> _scanRouter({bool automatic = false}) async {
    final gatewayIp = _profile?.gatewayIp;
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = automatic ? 'Reading Router Details' : 'Scanning Router';
      _ping = null;
    });

    final ping = await _routerScanService.pingGateway(gatewayIp ?? '');
    if (!mounted) return;

    setState(() {
      _ping = ping;
      _isScanning = false;
      _statusMessage = 'Router Scan Complete';
    });
  }

  Future<void> _autoScanConnectedRouter(WifiProfileModel? profile) async {
    if (!mounted || profile == null || !profile.isConnected || _isScanning) {
      return;
    }

    final gatewayIp = profile.gatewayIp?.trim();
    if (gatewayIp == null || gatewayIp.isEmpty) {
      return;
    }

    final networkKey = _networkKey(profile);
    if (networkKey == null) {
      return;
    }
    if (_lastAutoScannedNetworkKey == networkKey) {
      return;
    }

    _lastAutoScannedNetworkKey = networkKey;
    await _scanRouter(automatic: true);
  }

  String? _networkKey(WifiProfileModel? profile) {
    final gatewayIp = profile?.gatewayIp?.trim();
    if (gatewayIp == null || gatewayIp.isEmpty) return null;
    return '${profile?.ssid ?? 'unknown'}|$gatewayIp';
  }

  void _refreshWifiStatusAfterSettings() {
    _refreshWifiStatus();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted && _hasPermissions) _refreshWifiStatus();
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted && _hasPermissions) _refreshWifiStatus();
    });
  }

  Future<void> _useThisWifi() async {
    final profile = _profile;
    final ping = _ping;
    if (profile == null || ping == null) return;

    setState(() {
      _isSaving = true;
      _statusMessage = 'Wi-Fi Saved';
    });

    await _storageService.saveWifiProfile(profile, ping);
    if (!mounted) return;

    setState(() => _isSaving = false);
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute<void>(builder: (_) => const RouterLocationScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _appleInk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _profile?.isConnected ?? false;
    final canScan =
        isConnected && (_profile?.gatewayIp?.trim().isNotEmpty ?? false);
    final canUseWifi = isConnected && _ping != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _creamBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _creamBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _appleInk,
          centerTitle: true,
          title: const Text(
            'Wi-Fi Setup',
            style: TextStyle(
              color: _appleInk,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const Text(
                'Prepare SentriFi',
                style: TextStyle(
                  color: _appleInk,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Detect the current Wi-Fi, scan your router, and save the profile for sensing calibration.',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 24),
              if (!_hasPermissions)
                PermissionCard(
                  isRequesting: _isRequestingPermissions,
                  onAllowAccess: _requestPermissions,
                  onOpenAppSettings: _openAppSettings,
                )
              else ...[
                WifiStatusCard(
                  statusMessage: _statusMessage,
                  isChecking: _isChecking,
                  profile: _profile,
                  onOpenWifiSettings: _openWifiSettings,
                  onRetry: _refreshWifiStatus,
                ),
                if (isConnected) ...[
                  const SizedBox(height: 16),
                  RouterScanCard(
                    statusMessage: _statusMessage == 'Wi-Fi Connected'
                        ? 'Scan Router'
                        : _statusMessage,
                    isScanning: _isScanning,
                    isSaving: _isSaving,
                    canScan: canScan,
                    canUseWifi: canUseWifi,
                    ping: _ping,
                    onScanRouter: _scanRouter,
                    onUseThisWifi: _useThisWifi,
                  ),
                  if (!canScan) ...[
                    const SizedBox(height: 12),
                    const _InlineNote(
                      text:
                          'Gateway IP is unavailable. You can retry after checking Wi-Fi or location services.',
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  const _InlineNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _secondaryText,
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}
