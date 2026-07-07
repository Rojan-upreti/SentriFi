import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/wifi_connect_screen.dart';
import '../theme/app_theme.dart';

const _creamBackground = Color(0xFFF7F2EA);
const _appleInk = Color(0xFF1D1D1F);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _creamBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 520),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _showSplash
            ? const _SplashView(key: ValueKey('splash'))
            : const _ConnectWifiView(key: ValueKey('connect')),
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView({super.key});

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: _AnimatedSplashLogo(),
        ),
      ),
    );
  }
}

class _AnimatedSplashLogo extends StatelessWidget {
  const _AnimatedSplashLogo();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_SplashViewState>();
    final fade = state?._fade ?? const AlwaysStoppedAnimation<double>(1);
    final scale = state?._scale ?? const AlwaysStoppedAnimation<double>(1);

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sentri',
              style: TextStyle(
                color: _appleInk,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
            ),
            Text(
              'Fi',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectWifiView extends StatelessWidget {
  const _ConnectWifiView({super.key});

  void _openWifiSetup(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const WifiConnectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              _ConnectWifiButton(onPressed: () => _openWifiSetup(context)),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectWifiButton extends StatelessWidget {
  const _ConnectWifiButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Connect Wi-Fi',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: _appleInk,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CupertinoButton(
          onPressed: onPressed,
          color: Colors.transparent,
          disabledColor: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.wifi,
                color: Colors.white,
                size: 21,
              ),
              SizedBox(width: 10),
              Text(
                'Connect Wi-Fi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
