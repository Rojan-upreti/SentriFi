import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/router_ping_model.dart';

const _appleInk = Color(0xFF1D1D1F);
const _cardBackground = Color(0xFFFFFFFF);
const _secondaryText = Color(0xFF6E6E73);
const _successGreen = Color(0xFF248A3D);

class RouterScanCard extends StatelessWidget {
  const RouterScanCard({
    super.key,
    required this.statusMessage,
    required this.isScanning,
    required this.isSaving,
    required this.canScan,
    required this.canUseWifi,
    required this.ping,
    required this.onScanRouter,
    required this.onUseThisWifi,
  });

  final String statusMessage;
  final bool isScanning;
  final bool isSaving;
  final bool canScan;
  final bool canUseWifi;
  final RouterPingModel? ping;
  final VoidCallback onScanRouter;
  final VoidCallback onUseThisWifi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ping == null
                    ? CupertinoIcons.dot_radiowaves_left_right
                    : CupertinoIcons.checkmark_circle_fill,
                color: ping == null ? _appleInk : _successGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusMessage,
                  style: const TextStyle(
                    color: _appleInk,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ],
          ),
          if (ping?.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              ping!.errorMessage!,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
          if (ping != null) ...[
            const SizedBox(height: 22),
            _MetricGrid(ping: ping!),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Scan your router gateway 10 times to create a network baseline for sensing.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.2,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _PrimaryButton(
            label: isScanning ? 'Scanning Router' : 'Scan Router',
            icon: CupertinoIcons.waveform_path_ecg,
            isLoading: isScanning,
            onPressed: canScan && !isScanning && !isSaving ? onScanRouter : null,
          ),
          const SizedBox(height: 12),
          _SecondaryButton(
            label: isSaving ? 'Saving...' : 'Use This Wi-Fi',
            isLoading: isSaving,
            onPressed:
                canUseWifi && !isScanning && !isSaving ? onUseThisWifi : null,
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.ping});

  final RouterPingModel ping;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricTile(label: 'Average', value: '${ping.averageLatency.toStringAsFixed(1)} ms'),
        _MetricTile(label: 'Minimum', value: '${ping.minLatency} ms'),
        _MetricTile(label: 'Maximum', value: '${ping.maxLatency} ms'),
        _MetricTile(label: 'Jitter', value: '${ping.jitter.toStringAsFixed(1)} ms'),
        _MetricTile(
          label: 'Packet Loss',
          value: '${ping.packetLossPercentage.toStringAsFixed(0)}%',
        ),
        _MetricTile(
          label: 'Packets',
          value: '${ping.receivedPackets}/${ping.sentPackets}',
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _appleInk,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        color: _appleInk,
        disabledColor: _appleInk.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        minimumSize: const Size.fromHeight(56),
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        color: const Color(0xFFF5F5F7),
        disabledColor: const Color(0xFFE8E8ED),
        borderRadius: BorderRadius.circular(18),
        minimumSize: const Size.fromHeight(54),
        child: isLoading
            ? const CupertinoActivityIndicator()
            : Text(
                label,
                style: TextStyle(
                  color: onPressed == null
                      ? _secondaryText.withValues(alpha: 0.7)
                      : _appleInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }
}
