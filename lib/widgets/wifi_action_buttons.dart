import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WifiActionButtons extends StatelessWidget {
  const WifiActionButtons({
    super.key,
    required this.isConnected,
    required this.isScanning,
    required this.isSaving,
    required this.onScan,
    required this.onUseWifi,
    required this.onOpenSettings,
  });

  final bool isConnected;
  final bool isScanning;
  final bool isSaving;
  final VoidCallback onScan;
  final VoidCallback onUseWifi;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Open Wi-Fi Settings'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: isScanning || isSaving ? null : onScan,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isScanning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.radar_rounded),
            label: Text(isScanning ? 'Scanning...' : 'Scan Wi-Fi'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isScanning || isSaving ? null : onUseWifi,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(isSaving ? 'Saving Baseline...' : 'Use This Wi-Fi'),
          ),
        ),
      ],
    );
  }
}
