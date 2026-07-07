# SentriFi

A cross-platform Flutter app for iOS and Android with a polished login experience and animated SENTRIFI branding.

## Features

- **Animated SENTRIFI logo** — staggered letter reveal, shimmer gradient, and glow pulse
- **Login screen** — email/password form with validation, frosted glass card, and dark fintech theme
- **Wi-Fi setup screen** — connection status, SSID/BSSID/IP details, gateway ping baseline, and local persistence
- **Mobile optimized** — safe areas, keyboard handling, autofill hints, and platform system UI styling

## Getting Started

```bash
flutter pub get
flutter run
```

### Run on a specific device

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator / device
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── ping_result_model.dart
│   ├── wifi_baseline_model.dart
│   └── wifi_info_model.dart
├── screens/
│   ├── login_screen.dart
│   └── wifi_setup_screen.dart
├── services/
│   ├── wifi_scan_service.dart
│   └── wifi_storage_service.dart
├── theme/
│   └── app_theme.dart
├── utils/
│   ├── network_stats_util.dart
│   ├── permission_helper.dart
│   ├── ping_util.dart
│   ├── settings_launcher.dart
│   └── storage_keys.dart
└── widgets/
    ├── login_form.dart
    ├── ping_results_card.dart
    ├── sentrif_logo_animation.dart
    ├── wifi_action_buttons.dart
    ├── wifi_info_card.dart
    └── wifi_status_banner.dart
```
