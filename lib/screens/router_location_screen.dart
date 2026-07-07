import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calibration_screen.dart';

const _creamBackground = Color(0xFFF7F2EA);
const _appleInk = Color(0xFF1D1D1F);
const _secondaryText = Color(0xFF6E6E73);

class RouterLocationScreen extends StatefulWidget {
  const RouterLocationScreen({super.key});

  @override
  State<RouterLocationScreen> createState() => _RouterLocationScreenState();
}

class _RouterLocationScreenState extends State<RouterLocationScreen> {
  static const _locations = ['Living Room', 'Bedroom', 'Office', 'Garage'];

  final _customController = TextEditingController();
  String _selectedLocation = _locations.first;
  bool _isCustom = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _continue() {
    final location = _isCustom
        ? _customController.text.trim()
        : _selectedLocation;
    if (location.isEmpty) return;

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute<void>(
        builder: (_) => CalibrationScreen(routerLocation: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Router Location'),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const Text(
                'Where is your router?',
                style: TextStyle(
                  color: _appleInk,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'SentriFi will attach this location to the calibration baseline and future movement alerts.',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 24),
              _LocationCard(
                selectedLocation: _selectedLocation,
                isCustom: _isCustom,
                locations: _locations,
                customController: _customController,
                onSelect: (location) {
                  setState(() {
                    _selectedLocation = location;
                    _isCustom = false;
                  });
                },
                onCustomSelected: () => setState(() => _isCustom = true),
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: 'Continue to Calibration',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.selectedLocation,
    required this.isCustom,
    required this.locations,
    required this.customController,
    required this.onSelect,
    required this.onCustomSelected,
  });

  final String selectedLocation;
  final bool isCustom;
  final List<String> locations;
  final TextEditingController customController;
  final ValueChanged<String> onSelect;
  final VoidCallback onCustomSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          for (final location in locations)
            _LocationTile(
              label: location,
              selected: !isCustom && selectedLocation == location,
              onTap: () => onSelect(location),
            ),
          _LocationTile(
            label: 'Custom Location',
            selected: isCustom,
            onTap: onCustomSelected,
          ),
          if (isCustom) ...[
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: customController,
              placeholder: 'e.g. Upstairs Hallway',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: selected ? _appleInk : _secondaryText,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: _appleInk,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      color: _appleInk,
      borderRadius: BorderRadius.circular(18),
      minimumSize: const Size.fromHeight(56),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
