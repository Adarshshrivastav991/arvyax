import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

class HapticSettings {
  final double intensity; // 10 to 10000

  const HapticSettings({this.intensity = 100});

  HapticSettings copyWith({double? intensity}) {
    return HapticSettings(intensity: intensity ?? this.intensity);
  }
}

class HapticSettingsNotifier extends StateNotifier<HapticSettings> {
  HapticSettingsNotifier() : super(const HapticSettings()) {
    _instance = this;
  }

  static HapticSettingsNotifier? _instance;

  /// Global access for widgets without ref
  static Future<void> triggerHaptic() async {
    if (_instance != null) {
      await _instance!.executeHaptic(HapticType.medium);
    } else {
      // Fallback: direct vibration
      await Vibration.vibrate(duration: 20, amplitude: 128);
    }
  }

  static Future<void> triggerHeavyHaptic() async {
    if (_instance != null) {
      await _instance!.executeHaptic(HapticType.heavy);
    } else {
      await Vibration.vibrate(duration: 30, amplitude: 200);
    }
  }

  void setIntensity(double intensity) {
    state = state.copyWith(intensity: intensity.clamp(10, 10000));
  }

  // Execute haptic feedback based on intensity
  // Uses vibration plugin which works even when device haptic is disabled
  Future<void> executeHaptic(HapticType type) async {
    final intensity = state.intensity;

    // Check if vibration is supported
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    if (intensity < 40) {
      await Vibration.vibrate(duration: 10, amplitude: 50);
    } else if (intensity < 80) {
      await Vibration.vibrate(duration: 20, amplitude: 128);
    } else if (intensity < 150) {
      await Vibration.vibrate(duration: 30, amplitude: 200);
    } else if (intensity < 300) {
      await Vibration.vibrate(duration: 40, amplitude: 255);
      await Future.delayed(const Duration(milliseconds: 30));
      await Vibration.vibrate(duration: 40, amplitude: 255);
    } else if (intensity < 500) {
      await Vibration.vibrate(duration: 50, amplitude: 255);
      await Future.delayed(const Duration(milliseconds: 25));
      await Vibration.vibrate(duration: 50, amplitude: 255);
      await Future.delayed(const Duration(milliseconds: 25));
      await Vibration.vibrate(duration: 50, amplitude: 255);
    } else if (intensity < 1000) {
      for (int i = 0; i < 4; i++) {
        await Vibration.vibrate(duration: 60, amplitude: 255);
        await Future.delayed(const Duration(milliseconds: 20));
      }
    } else {
      for (int i = 0; i < 6; i++) {
        await Vibration.vibrate(duration: 80, amplitude: 255);
        await Future.delayed(const Duration(milliseconds: 15));
      }
    }
  }
}

enum HapticType { light, medium, heavy }

final hapticSettingsProvider =
    StateNotifierProvider<HapticSettingsNotifier, HapticSettings>((ref) {
      return HapticSettingsNotifier();
    });
