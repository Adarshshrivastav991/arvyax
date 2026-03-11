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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.orange,
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            thumbColor: AppColors.orange,
            overlayColor: AppColors.orange.withValues(alpha: 0.15),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(value: progress.clamp(0.0, 1.0), onChanged: onSeek),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TimeFormatter.formatDuration(elapsedSeconds),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.orange,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                TimeFormatter.formatDuration(totalSeconds),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
