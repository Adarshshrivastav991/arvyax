import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class AmbienceSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String value;

  const AmbienceSearchBar({
    super.key,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.08),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.75),
                    Colors.white.withValues(alpha: 0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
        ),
        child: TextField(
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search sessions...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.orange.withValues(alpha: 0.7),
              size: 22,
            ),
            suffixIcon: value.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      HapticSettingsNotifier.triggerHaptic();
                      onChanged('');
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}
