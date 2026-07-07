import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/wifi_signal_sample_model.dart';
import '../services/calibration_service.dart';
import 'home_screen.dart';

const _creamBackground = Color(0xFFF7F2EA);
const _appleInk = Color(0xFF1D1D1F);
const _secondaryText = Color(0xFF6E6E73);
const _successGreen = Color(0xFF248A3D);

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key, required this.routerLocation});

  final String routerLocation;

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen>
    with SingleTickerProviderStateMixin {
  static const _durationSeconds = 60;

  final _calibrationService = CalibrationService();
  final _samples = <WifiSignalSampleModel>[];

  late final AnimationController _scanController;
  Timer? _timer;
  int _remainingSeconds = _durationSeconds;
  bool _isRunning = false;
  bool _isSaving = false;
  bool _isCapturingSample = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _startCalibration() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _remainingSeconds = _durationSeconds;
      _samples.clear();
      _errorMessage = null;
    });

    await _captureSample();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      setState(() => _remainingSeconds--);
      final elapsed = _durationSeconds - _remainingSeconds;
      if (elapsed % 5 == 0 && _remainingSeconds > 0) {
        await _captureSample();
      }
      if (_remainingSeconds <= 0) {
        await _completeCalibration();
      }
    });
  }

  Future<void> _captureSample() async {
    if (_isCapturingSample) return;
    _isCapturingSample = true;
    try {
      final sample = await _calibrationService.captureCalibrationSample();
      if (mounted) setState(() => _samples.add(sample));
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to read Wi-Fi signal: $error');
      }
    } finally {
      _isCapturingSample = false;
    }
  }

  Future<void> _completeCalibration() async {
    _timer?.cancel();
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _isRunning = false;
    });

    try {
      if (_samples.isEmpty) {
        await _captureSample();
      }
      await _calibrationService.saveBaseline(
        routerLocation: widget.routerLocation,
        samples: _samples,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute<void>(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Calibration could not be saved: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / _durationSeconds);

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
          title: const Text('Calibration'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(
                'Calibrate ${widget.routerLocation}',
                style: const TextStyle(
                  color: _appleInk,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'SentriFi needs 1 minute to learn the normal Wi-Fi signal pattern of this environment.',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 24),
              _ScanCard(
                animation: _scanController,
                remainingSeconds: _remainingSeconds,
                progress: progress,
                isRunning: _isRunning,
                isSaving: _isSaving,
                samplesCount: _samples.length,
              ),
              const SizedBox(height: 16),
              const _InstructionCard(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _InlineError(message: _errorMessage!),
              ],
              const SizedBox(height: 24),
              CupertinoButton(
                onPressed: _isRunning || _isSaving ? null : _startCalibration,
                color: _appleInk,
                disabledColor: _appleInk.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18),
                minimumSize: const Size.fromHeight(56),
                child: _isSaving
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        _isRunning
                            ? 'Calibration Running'
                            : 'Start 60-Second Scan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.animation,
    required this.remainingSeconds,
    required this.progress,
    required this.isRunning,
    required this.isSaving,
    required this.samplesCount,
  });

  final Animation<double> animation;
  final int remainingSeconds;
  final double progress;
  final bool isRunning;
  final bool isSaving;
  final int samplesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanningPainter(animation.value, progress),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$remainingSeconds',
                          style: const TextStyle(
                            color: _appleInk,
                            fontSize: 54,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        const Text(
                          'seconds',
                          style: TextStyle(color: _secondaryText),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSaving
                ? 'Saving baseline...'
                : isRunning
                ? 'Analyzing signal pattern'
                : 'Ready to scan',
            style: const TextStyle(
              color: _appleInk,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$samplesCount samples collected',
            style: const TextStyle(color: _secondaryText),
          ),
        ],
      ),
    );
  }
}

class _ScanningPainter extends CustomPainter {
  const _ScanningPainter(this.phase, this.progress);

  final double phase;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = _appleInk.withValues(alpha: 0.08);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = _successGreen;

    canvas.drawCircle(center, radius - 8, ringPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      progressPaint,
    );

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _appleInk.withValues(alpha: 0.14 * (1 - phase));
    canvas.drawCircle(center, 32 + (phase * (radius - 46)), pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _ScanningPainter oldDelegate) {
    return phase != oldDelegate.phase || progress != oldDelegate.progress;
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) {
    const instructions = [
      'Please keep the area near the router still during calibration.',
      'No one should walk around the router or monitored area for the next 60 seconds.',
      'Place your phone in a stable position and keep it connected to the same Wi-Fi network.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before you start',
            style: TextStyle(
              color: _appleInk,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final instruction in instructions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(CupertinoIcons.checkmark_circle, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Color(0xFFB3261E), height: 1.35),
    );
  }
}
