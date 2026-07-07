import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WifiStatusBanner extends StatelessWidget {
  const WifiStatusBanner({super.key, required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.primary : AppColors.error;
    final icon = isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final label = isConnected ? 'Wi-Fi Connected' : 'No Wi-Fi Connected';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
