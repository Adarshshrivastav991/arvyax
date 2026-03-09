import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/haptic_settings_provider.dart';
import '../../shared/theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticSettings = ref.watch(hapticSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            HapticSettingsNotifier.triggerHaptic();
            context.pop();
          },
        ),
        title: const Text('Haptic Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Haptic Section
          _buildSectionTitle(context, 'HAPTIC FEEDBACK'),
          const SizedBox(height: 12),
          _buildFrostedCard(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vibration Intensity',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${hapticSettings.intensity.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getIntensityLabel(hapticSettings.intensity),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getIntensityColor(hapticSettings.intensity),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.orange,
                      inactiveTrackColor: AppColors.textSecondaryLight
                          .withValues(alpha: 0.3),
                      thumbColor: AppColors.orange,
                      overlayColor: AppColors.orange.withValues(alpha: 0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: _sliderValue(hapticSettings.intensity),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) {
                        final intensity = _intensityFromSlider(value);
                        ref
                            .read(hapticSettingsProvider.notifier)
                            .setIntensity(intensity);
                      },
                      onChangeEnd: (value) {
                        // Test haptic on release
                        ref
                            .read(hapticSettingsProvider.notifier)
                            .executeHaptic(HapticType.heavy);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Low (10%)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Ultra High (10000%)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Test button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(hapticSettingsProvider.notifier)
                            .executeHaptic(HapticType.heavy);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vibration, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Test Vibration',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Quick Presets
          _buildSectionTitle(context, 'QUICK PRESETS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPresetChip(
                context,
                ref,
                isDark,
                'Subtle',
                25,
                Icons.volume_mute_rounded,
              ),
              _buildPresetChip(
                context,
                ref,
                isDark,
                'Normal',
                100,
                Icons.volume_down_rounded,
              ),
              _buildPresetChip(
                context,
                ref,
                isDark,
                'Strong',
                200,
                Icons.volume_up_rounded,
              ),
              _buildPresetChip(
                context,
                ref,
                isDark,
                'Extreme',
                500,
                Icons.bolt_rounded,
              ),
              _buildPresetChip(
                context,
                ref,
                isDark,
                'Insane',
                2000,
                Icons.rocket_launch_rounded,
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
        color: AppColors.orange,
      ),
    );
  }

  Widget _buildFrostedCard({required bool isDark, required Widget child}) {
    return Container(
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String label,
    double intensity,
    IconData icon,
  ) {
    final currentIntensity = ref.watch(hapticSettingsProvider).intensity;
    final isSelected = (currentIntensity - intensity).abs() < 1;

    return GestureDetector(
      onTap: () {
        ref.read(hapticSettingsProvider.notifier).setIntensity(intensity);
        ref
            .read(hapticSettingsProvider.notifier)
            .executeHaptic(HapticType.heavy);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.orange.withValues(alpha: 0.8),
                    AppColors.orange.withValues(alpha: 0.6),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.5),
                        ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.orange
                : isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.8),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? AppColors.textSecondaryLight
                  : AppColors.textPrimaryDark,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? AppColors.textSecondaryLight
                    : AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIntensityLabel(double intensity) {
    if (intensity < 40) return 'Subtle - Light vibrations';
    if (intensity < 80) return 'Normal - Moderate feedback';
    if (intensity < 150) return 'Strong - Heavy vibrations';
    if (intensity < 300) return 'Ultra - Double impact';
    if (intensity < 500) return 'Extreme - Triple burst';
    if (intensity < 1000) return 'Mega - Rapid fire';
    return 'INSANE - Maximum intensity';
  }

  Color _getIntensityColor(double intensity) {
    if (intensity < 80) return Colors.green;
    if (intensity < 200) return Colors.blue;
    if (intensity < 500) return Colors.orange;
    return Colors.red;
  }

  // Logarithmic mapping for slider (10 to 10000)
  double _sliderValue(double intensity) {
    // Map 10-10000 to 0-100 logarithmically
    final logMin = math.log(10);
    final logMax = math.log(10000);
    final logValue = math.log(intensity.clamp(10, 10000));
    return ((logValue - logMin) / (logMax - logMin)) * 100;
  }

  double _intensityFromSlider(double sliderValue) {
    // Map 0-100 to 10-10000 logarithmically
    final logMin = math.log(10);
    final logMax = math.log(10000);
    final logValue = logMin + (sliderValue / 100) * (logMax - logMin);
    return math.exp(logValue).clamp(10, 10000);
  }
}
