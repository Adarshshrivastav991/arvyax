import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../providers/haptic_settings_provider.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onButtonPressed == null
                    ? null
                    : () {
                        HapticSettingsNotifier.triggerHaptic();
                        onButtonPressed!();
                      },
                style: TextButton.styleFrom(foregroundColor: AppColors.orange),
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
