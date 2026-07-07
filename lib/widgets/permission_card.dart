import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _appleInk = Color(0xFF1D1D1F);
const _cardBackground = Color(0xFFFFFFFF);
const _secondaryText = Color(0xFF6E6E73);

class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.isRequesting,
    required this.onAllowAccess,
    required this.onOpenAppSettings,
  });

  final bool isRequesting;
  final VoidCallback onAllowAccess;
  final VoidCallback onOpenAppSettings;

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
          const Icon(CupertinoIcons.lock_shield, color: _appleInk, size: 30),
          const SizedBox(height: 18),
          const Text(
            'Permission Required',
            style: TextStyle(
              color: _appleInk,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'SentriFi needs Wi-Fi and local network access to detect your home router and use this phone as a security sensor.',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 16,
              height: 1.45,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: isRequesting ? 'Requesting...' : 'Allow Access',
            isLoading: isRequesting,
            onPressed: isRequesting ? null : onAllowAccess,
          ),
          const SizedBox(height: 12),
          _SecondaryButton(
            label: 'Open App Settings',
            onPressed: isRequesting ? null : onOpenAppSettings,
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
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
        color: _appleInk,
        borderRadius: BorderRadius.circular(18),
        minimumSize: const Size.fromHeight(56),
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

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
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
