import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipForward;
  final VoidCallback onSkipBackward;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipForward,
    required this.onSkipBackward,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            HapticSettingsNotifier.triggerHaptic();
            onSkipBackward();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.replay_10_rounded,
              size: 28,
              color: isDark
                  ? AppColors.textPrimaryDark.withValues(alpha: 0.7)
                  : AppColors.textPrimaryLight.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: () {
            HapticSettingsNotifier.triggerHeavyHaptic();
            onPlayPause();
          },
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.orange, AppColors.orangeLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isPlaying),
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: () {
            HapticSettingsNotifier.triggerHaptic();
            onSkipForward();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forward_10_rounded,
              size: 28,
              color: isDark
                  ? AppColors.textPrimaryDark.withValues(alpha: 0.7)
                  : AppColors.textPrimaryLight.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
