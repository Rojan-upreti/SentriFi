import 'dart:io';

import '../models/ping_result_model.dart';

class PingUtil {
  static const _probePorts = [80, 443, 53];

  static Future<PingResultModel> pingHost(
    String host, {
    required int sequence,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final shellLatency = await _pingWithShell(host, timeout: timeout);
      if (shellLatency != null) {
        return PingResultModel(
          sequence: sequence,
          success: true,
          latencyMs: shellLatency,
        );
      }
    }

    for (final port in _probePorts) {
      final latency = await _tcpLatency(host, port, timeout: timeout);
      if (latency != null) {
        return PingResultModel(
          sequence: sequence,
          success: true,
          latencyMs: latency,
        );
      }
    }

    return PingResultModel(sequence: sequence, success: false);
  }

  static Future<int?> _pingWithShell(
    String host, {
    required Duration timeout,
  }) async {
    try {
      final waitFlag = Platform.isIOS ? '-W' : '-W';
      final waitValue = Platform.isIOS ? '${timeout.inMilliseconds}' : '1';

      final result = await Process.run('ping', [
        '-c',
        '1',
        waitFlag,
        waitValue,
        host,
      ]);

      if (result.exitCode != 0) return null;

      final output = '${result.stdout}';
      final match = RegExp(r'time[=<](\d+(?:\.\d+)?)\s*ms').firstMatch(output);
      if (match != null) {
        return double.parse(match.group(1)!).round();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<int?> _tcpLatency(
    String host,
    int port, {
    required Duration timeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      stopwatch.stop();
      await socket.close();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      stopwatch.stop();
      return null;
    }
  }
}
