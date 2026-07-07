import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/home_monitoring_controller.dart';
import 'router_location_screen.dart';

const _creamBackground = Color(0xFFF7F2EA);
const _appleInk = Color(0xFF1D1D1F);
const _secondaryText = Color(0xFF6E6E73);
const _alertRed = Color(0xFFB3261E);
const _successGreen = Color(0xFF248A3D);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeMonitoringController()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
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
        body: SafeArea(
          child: Consumer<HomeMonitoringController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }

              final profile = controller.profile;
              if (profile == null) {
                return _EmptyHome(
                  onCalibrate: () => _startCalibration(context),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  const Text(
                    'SentriFi Home',
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
                    'Monitor Wi-Fi signal behavior near your router area.',
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _StatusCard(controller: controller),
                  const SizedBox(height: 16),
                  _DetectionCard(controller: controller),
                  const SizedBox(height: 24),
                  _ArmButton(controller: controller),
                  const SizedBox(height: 12),
                  CupertinoButton(
                    onPressed: () => _startCalibration(context),
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(18),
                    minimumSize: const Size.fromHeight(54),
                    child: const Text(
                      'Recalibrate Router Area',
                      style: TextStyle(
                        color: _appleInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _startCalibration(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const RouterLocationScreen()),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});

  final HomeMonitoringController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile!;
    final sample = controller.latestSample;
    final connected = sample?.isConnected ?? true;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                connected ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                color: connected ? _successGreen : _alertRed,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                connected ? 'Wi-Fi Connected' : 'Wi-Fi Disconnected',
                style: const TextStyle(
                  color: _appleInk,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Network', value: profile.displaySsid),
          _InfoRow(
            label: 'Router Location',
            value: profile.displayRouterLocation,
          ),
          _InfoRow(
            label: 'Last Calibration',
            value: _formatDate(profile.lastCalibratedAt),
          ),
          _InfoRow(
            label: 'Gateway IP',
            value: profile.gatewayIp ?? 'Unavailable',
          ),
          if (sample?.rssi != null)
            _InfoRow(label: 'Current RSSI', value: '${sample!.rssi} dBm'),
          if (sample?.linkSpeed != null)
            _InfoRow(label: 'Link Speed', value: '${sample!.linkSpeed} Mbps'),
        ],
      ),
    );
  }
}

class _DetectionCard extends StatelessWidget {
  const _DetectionCard({required this.controller});

  final HomeMonitoringController controller;

  @override
  Widget build(BuildContext context) {
    final alert = controller.latestAlert;
    final movement = controller.isMovementSuspected;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                movement
                    ? CupertinoIcons.exclamationmark_triangle_fill
                    : CupertinoIcons.shield_lefthalf_fill,
                color: movement ? _alertRed : _successGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Status',
                style: TextStyle(
                  color: _appleInk,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            controller.detectionStatus,
            style: TextStyle(
              color: movement ? _alertRed : _secondaryText,
              fontSize: 16,
              height: 1.4,
              fontWeight: movement ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (alert != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _alertRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                alert.message,
                style: const TextStyle(
                  color: _alertRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArmButton extends StatelessWidget {
  const _ArmButton({required this.controller});

  final HomeMonitoringController controller;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: controller.isArmed ? controller.disarm : controller.arm,
      color: controller.isArmed ? _alertRed : _appleInk,
      borderRadius: BorderRadius.circular(18),
      minimumSize: const Size.fromHeight(60),
      child: Text(
        controller.isArmed ? 'DISARM' : 'ARM',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onCalibrate});

  final VoidCallback onCalibrate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.wifi, color: _appleInk, size: 36),
              const SizedBox(height: 16),
              const Text(
                'Calibration Required',
                style: TextStyle(
                  color: _appleInk,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect Wi-Fi and create a baseline before monitoring.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _secondaryText, height: 1.4),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: onCalibrate,
                color: _appleInk,
                borderRadius: BorderRadius.circular(18),
                child: const Text('Start Calibration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 14,
                letterSpacing: -0.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _appleInk,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year} $hour:$minute $suffix';
}
