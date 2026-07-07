import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/network_stats_util.dart';

class PingResultsCard extends StatelessWidget {
  const PingResultsCard({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  final ({
    double averageLatencyMs,
    double minLatencyMs,
    double maxLatencyMs,
    double jitterMs,
    double packetLossPercent,
  })? stats;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Pinging gateway (${NetworkStatsUtil.baselinePingCount} packets)...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (stats == null) return const SizedBox.shrink();

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
            'Ping Baseline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _MetricRow(
            label: 'Average Latency',
            value: '${stats!.averageLatencyMs.toStringAsFixed(1)} ms',
          ),
          _MetricRow(
            label: 'Minimum Latency',
            value: '${stats!.minLatencyMs.toStringAsFixed(1)} ms',
          ),
          _MetricRow(
            label: 'Maximum Latency',
            value: '${stats!.maxLatencyMs.toStringAsFixed(1)} ms',
          ),
          _MetricRow(
            label: 'Jitter',
            value: '${stats!.jitterMs.toStringAsFixed(1)} ms',
          ),
          _MetricRow(
            label: 'Packet Loss',
            value: '${stats!.packetLossPercent.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
