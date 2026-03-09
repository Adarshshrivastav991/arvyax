import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/ambience_controller.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/utils/time_formatter.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/providers/haptic_settings_provider.dart';
import '../../player/controller/session_controller.dart';
import '../../player/widgets/mini_player.dart';

class AmbienceDetailsScreen extends ConsumerWidget {
  final String ambienceId;

  const AmbienceDetailsScreen({super.key, required this.ambienceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(ambienceId));
    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      body: ambienceAsync.when(
        data: (ambience) {
          if (ambience == null) {
            return const Center(child: Text('Ambience not found'));
          }
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          HapticSettingsNotifier.triggerHaptic();
                          context.pop();
                        },
                      ),
                      actions: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            HapticSettingsNotifier.triggerHaptic();
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildHeroImage(ambience.tag),
                      ),
                      title: const Text('Ambience Details'),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ambience.title,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildBadge(
                                  context,
                                  icon: _tagIcon(ambience.tag),
                                  label: ambience.tag,
                                  color: _tagColor(ambience.tag),
                                ),
                                const SizedBox(width: 10),
                                _buildBadge(
                                  context,
                                  icon: Icons.access_time,
                                  label: TimeFormatter.formatMinutes(
                                    ambience.duration,
                                  ),
                                  color: AppColors.textSecondaryLight,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              ambience.description,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    height: 1.6,
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'SENSORY RECIPE',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ambience.recipe.map((r) {
                                return _buildRecipeChip(context, r);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (sessionState.isSessionActive)
                MiniPlayer(onTap: () => context.push('/player')),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: PrimaryButton(
                    label: 'Start Session',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      ref
                          .read(sessionControllerProvider.notifier)
                          .startSession(ambience);
                      context.push('/player');
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeroImage(String tag) {
    final color = _tagColor(tag);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          _tagIcon(tag),
          size: 80,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeChip(BuildContext context, String label) {
    final chipData = _recipeChipData(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: chipData.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipData.icon, size: 18, color: chipData.textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: chipData.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Focus':
        return AppColors.focusTag;
      case 'Calm':
        return AppColors.calmTag;
      case 'Sleep':
        return AppColors.sleepTag;
      case 'Reset':
        return AppColors.resetTag;
      default:
        return AppColors.focusTag;
    }
  }

  IconData _tagIcon(String tag) {
    switch (tag) {
      case 'Focus':
        return Icons.flare;
      case 'Calm':
        return Icons.water_drop;
      case 'Sleep':
        return Icons.nights_stay;
      case 'Reset':
        return Icons.refresh;
      default:
        return Icons.flare;
    }
  }

  _RecipeChipStyle _recipeChipData(String label) {
    switch (label.toLowerCase()) {
      case 'breeze':
      case 'sea breeze':
      case 'cool breeze':
      case 'wind':
        return _RecipeChipStyle(
          AppColors.chipBreeze,
          Icons.air,
          const Color(0xFF5B8DB8),
        );
      case 'warm light':
      case 'soft light':
        return _RecipeChipStyle(
          AppColors.chipWarmLight,
          Icons.wb_sunny,
          const Color(0xFFD4A017),
        );
      case 'mist':
      case 'cool mist':
        return _RecipeChipStyle(
          AppColors.chipMist,
          Icons.cloud,
          const Color(0xFF78909C),
        );
      case 'binaural':
        return _RecipeChipStyle(
          AppColors.chipBinaural,
          Icons.headphones,
          const Color(0xFF9C27B0),
        );
      case 'rain':
      case 'rain drops':
      case 'soft rain':
        return _RecipeChipStyle(
          AppColors.chipRain,
          Icons.water,
          const Color(0xFF0288D1),
        );
      case 'waves':
        return _RecipeChipStyle(
          AppColors.chipRain,
          Icons.waves,
          const Color(0xFF0288D1),
        );
      case 'white noise':
        return _RecipeChipStyle(
          AppColors.chipDefault,
          Icons.graphic_eq,
          const Color(0xFF607D8B),
        );
      case 'birdsong':
        return _RecipeChipStyle(
          AppColors.chipWarmLight,
          Icons.music_note,
          const Color(0xFF689F38),
        );
      case 'crickets':
        return _RecipeChipStyle(
          AppColors.chipDefault,
          Icons.grass,
          const Color(0xFF558B2F),
        );
      case 'soft bells':
        return _RecipeChipStyle(
          AppColors.chipWarmLight,
          Icons.notifications,
          const Color(0xFFFF8F00),
        );
      case 'thunder':
        return _RecipeChipStyle(
          AppColors.chipMist,
          Icons.flash_on,
          const Color(0xFF546E7A),
        );
      case 'fireplace':
        return _RecipeChipStyle(
          AppColors.chipWarmLight,
          Icons.local_fire_department,
          const Color(0xFFE65100),
        );
      case 'night sounds':
        return _RecipeChipStyle(
          AppColors.chipBinaural,
          Icons.dark_mode,
          const Color(0xFF3F51B5),
        );
      default:
        return _RecipeChipStyle(
          AppColors.chipDefault,
          Icons.auto_awesome,
          const Color(0xFF757575),
        );
    }
  }
}

class _RecipeChipStyle {
  final Color color;
  final IconData icon;
  final Color textColor;

  _RecipeChipStyle(this.color, this.icon, this.textColor);
}
