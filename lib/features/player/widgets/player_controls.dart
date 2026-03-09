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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            HapticSettingsNotifier.triggerHaptic();
            onSkipBackward();
          },
          icon: const Icon(Icons.replay_10),
          iconSize: 36,
          color: AppColors.textPrimaryLight.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () {
            HapticSettingsNotifier.triggerHeavyHaptic();
            onPlayPause();
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          onPressed: () {
            HapticSettingsNotifier.triggerHaptic();
            onSkipForward();
          },
          icon: const Icon(Icons.forward_10),
          iconSize: 36,
          color: AppColors.textPrimaryLight.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}
