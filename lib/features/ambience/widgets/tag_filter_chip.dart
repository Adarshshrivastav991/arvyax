import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class TagFilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TagFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<TagFilterChip> createState() => _TagFilterChipState();
}

class _TagFilterChipState extends State<TagFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.orange,
                        AppColors.orange.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.08),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 0.5),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.3,
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
