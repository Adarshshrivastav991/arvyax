import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const List<_MoodOption> _moods = [
    _MoodOption('Calm', Icons.spa_rounded, AppColors.moodCalm),
    _MoodOption('Grounded', Icons.landscape_rounded, AppColors.moodGrounded),
    _MoodOption('Energized', Icons.bolt_rounded, AppColors.moodEnergized),
    _MoodOption('Sleepy', Icons.dark_mode_rounded, AppColors.moodSleepy),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _moods.map((mood) {
        final isSelected = selectedMood == mood.label;
        return _MoodChip(
          mood: mood,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () => onMoodSelected(mood.label),
        );
      }).toList(),
    );
  }
}

class _MoodChip extends StatefulWidget {
  final _MoodOption mood;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<_MoodChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            HapticSettingsNotifier.triggerHaptic();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.mood.color.withValues(alpha: 0.5),
                        widget.mood.color.withValues(alpha: 0.75),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isDark
                          ? [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.06),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 0.5),
                            ],
                    ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.orange.withValues(alpha: 0.5)
                    : widget.isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.8),
                width: widget.isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.mood.icon,
                  size: 20,
                  color: widget.isSelected
                      ? AppColors.textPrimaryLight
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.mood.label,
                  style: TextStyle(
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColors.textPrimaryLight
                        : AppColors.textSecondaryLight,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodOption {
  final String label;
  final IconData icon;
  final Color color;

  const _MoodOption(this.label, this.icon, this.color);
}
