import 'package:flutter/material.dart';

import '../models/wifi_info_model.dart';
import '../theme/app_theme.dart';

class WifiInfoCard extends StatelessWidget {
  const WifiInfoCard({
    super.key,
    required this.wifiInfo,
  });

  final WifiInfoModel wifiInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'SSID', value: wifiInfo.ssid ?? 'Unavailable'),
          _InfoRow(label: 'BSSID', value: wifiInfo.bssid ?? 'Unavailable'),
          _InfoRow(
            label: 'Gateway IP',
            value: wifiInfo.gatewayIp ?? 'Unavailable',
          ),
          _InfoRow(
            label: 'Phone Local IP',
            value: wifiInfo.localIp ?? 'Unavailable',
          ),
        ],
      ),
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
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
