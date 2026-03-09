import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/utils/time_formatter.dart';

class SessionProgressBar extends StatelessWidget {
  final int elapsedSeconds;
  final int totalSeconds;
  final ValueChanged<double>? onSeek;

  const SessionProgressBar({
    super.key,
    required this.elapsedSeconds,
    required this.totalSeconds,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.orange,
            inactiveTrackColor: AppColors.textSecondaryLight.withValues(
              alpha: 0.2,
            ),
            thumbColor: AppColors.orange,
            overlayColor: AppColors.orange.withValues(alpha: 0.2),
          ),
          child: Slider(value: progress.clamp(0.0, 1.0), onChanged: onSeek),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TimeFormatter.formatDuration(elapsedSeconds),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                TimeFormatter.formatDuration(totalSeconds),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
