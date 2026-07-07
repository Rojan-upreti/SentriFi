# Sentrifi

**Turn Your Wi-Fi Router Into a Home Security Alarm**

Sentrifi is a privacy-first mobile application that transforms an ordinary Wi-Fi router into a smart motion detection system. By analyzing wireless signal behavior and environmental patterns, Sentrifi can detect unusual movement around a monitored area without requiring cameras, sensors, or additional hardware.

## 🚀 Overview

Sentrifi learns the normal wireless characteristics of a space and continuously monitors for signal disturbances that may indicate movement nearby.

Whether you're monitoring an entryway, office, living room, or apartment, Sentrifi provides an affordable and accessible layer of home awareness using the Wi-Fi infrastructure you already own.

## ✨ Features

* 📡 Wi-Fi signal calibration and baseline learning
* 🏠 Assign custom router locations (Living Room, Bedroom, Office, etc.)
* ⏱️ One-minute environment analysis during setup
* 🧠 Local pattern recognition for signal fluctuations
* 🚨 Motion and occupancy anomaly detection
* 🔐 Privacy-first architecture
* 💾 Local SQLite storage
* 📱 Native Flutter experience for iOS and Android
* 🎨 Interface inspired by Apple Human Interface Guidelines

## ⚙️ How It Works

### 1. Connect

Select the Wi-Fi network you want to monitor.

### 2. Calibrate

Sentrifi analyzes the wireless environment for 60 seconds to establish a baseline signal profile.

During calibration, users are instructed to keep the monitored area still so the system can accurately learn normal network behavior.

### 3. Store

Calibration data is securely stored locally on the device using SQLite.

### 4. Arm

Tap the **ARM** button to begin monitoring.

### 5. Detect

Sentrifi continuously compares current network characteristics against the saved baseline.

If significant deviations are detected, the app alerts the user with messages such as:

> Possible movement detected near Living Room Router

or

> Suspected activity detected within the monitored area

## 🏗️ Tech Stack

* Flutter
* Dart
* SQLite
* Connectivity Plus
* Network Info Plus
* Permission Handler
* Shared Preferences

## 🎯 Vision

Traditional home security systems rely on cameras, subscriptions, or dedicated hardware.

Sentrifi explores a different approach:

**Using existing Wi-Fi infrastructure as a software-defined sensing layer for home awareness and occupancy detection.**

Our goal is to make home monitoring more accessible, affordable, and privacy-conscious for everyone.

## 📌 Current Status



Future iterations may include:

* Multi-router support
* Push notifications
* Historical activity timeline
* Room-level calibration profiles
* Machine learning–based anomaly detection
* Cross-device synchronization
* Smart home integrations

## 🔒 Privacy

Sentrifi is designed with a local-first philosophy.

All calibration data, network profiles, and monitoring information remain stored on the user's device.



---

**Sentrifi — Turn Your Wi-Fi Into a Security System.**
