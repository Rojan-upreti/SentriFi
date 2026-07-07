import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/wifi_profile_model.dart';

const _appleInk = Color(0xFF1D1D1F);
const _cardBackground = Color(0xFFFFFFFF);
const _secondaryText = Color(0xFF6E6E73);

class WifiStatusCard extends StatelessWidget {
  const WifiStatusCard({
    super.key,
    required this.statusMessage,
    required this.isChecking,
    required this.profile,
    required this.onOpenWifiSettings,
    required this.onRetry,
  });

  final String statusMessage;
  final bool isChecking;
  final WifiProfileModel? profile;
  final VoidCallback onOpenWifiSettings;
  final VoidCallback onRetry;

  bool get _isConnected => profile?.isConnected ?? false;

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
              AnimatedWifiIcon(active: _isConnected || isChecking),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  statusMessage,
                  style: const TextStyle(
                    color: _appleInk,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ],
          ),
          if (_isConnected && profile != null) ...[
            const SizedBox(height: 22),
            _DetailRow(label: 'SSID', value: profile!.displaySsid),
            _DetailRow(label: 'BSSID', value: profile!.displayBssid),
            _DetailRow(label: 'Gateway IP', value: profile!.displayGatewayIp),
            _DetailRow(label: 'Phone IP', value: profile!.displayLocalIp),
            _DetailRow(label: 'Subnet Mask', value: profile!.displaySubnetMask),
            _DetailRow(
              label: 'Broadcast',
              value: profile!.displayBroadcastAddress,
            ),
            _DetailRow(label: 'Connection', value: profile!.connectionType),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Connect this phone to your home Wi-Fi to continue.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 16,
                height: 1.4,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 22),
            _PrimaryButton(
              label: 'Open Wi-Fi Settings',
              icon: CupertinoIcons.settings,
              onPressed: onOpenWifiSettings,
            ),
            const SizedBox(height: 12),
            _SecondaryButton(label: 'Retry', onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}

class AnimatedWifiIcon extends StatefulWidget {
  const AnimatedWifiIcon({super.key, required this.active});

  final bool active;

  @override
  State<AnimatedWifiIcon> createState() => _AnimatedWifiIconState();
}

class _AnimatedWifiIconState extends State<AnimatedWifiIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.active ? 1 + (_controller.value * 0.08) : 1.0;
        final opacity = widget.active ? 0.2 + (_controller.value * 0.2) : 0.12;

        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _appleInk.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
          child: Transform.scale(
            scale: scale,
            child: const Icon(
              CupertinoIcons.wifi,
              color: _appleInk,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            width: 112,
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        color: _appleInk,
        borderRadius: BorderRadius.circular(18),
        minimumSize: const Size.fromHeight(56),
        child: Row(
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
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(18),
        minimumSize: const Size.fromHeight(54),
        child: Text(
          label,
          style: const TextStyle(
            color: _appleInk,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
