import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/ambience_controller.dart';
import '../widgets/ambience_card.dart';
import '../widgets/tag_filter_chip.dart';
import '../widgets/search_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';
import '../../player/controller/session_controller.dart';
import '../../player/widgets/mini_player.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAmbiences = ref.watch(filteredAmbiencesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTag = ref.watch(selectedTagProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: const Text('Ambiences'),
        actions: [
          // Theme toggle button
          GestureDetector(
            onTap: () {
              HapticSettingsNotifier.triggerHaptic();
              ref.read(themeProvider.notifier).toggleTheme();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    RotationTransition(turns: anim, child: child),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  size: 22,
                  color: isDark ? AppColors.orangeLight : AppColors.orange,
                ),
              ),
            ),
          ),
          // Settings button
          GestureDetector(
            onTap: () {
              HapticSettingsNotifier.triggerHaptic();
              context.push('/settings');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_rounded,
                size: 22,
                color: isDark ? AppColors.orangeLight : AppColors.orange,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              cacheExtent: 600,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AmbienceSearchBar(
                      value: searchQuery,
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            ref,
                            'Focus',
                            Icons.flare,
                            selectedTag,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChip(
                            ref,
                            'Calm',
                            Icons.water_drop,
                            selectedTag,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChip(
                            ref,
                            'Sleep',
                            Icons.nights_stay,
                            selectedTag,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChip(
                            ref,
                            'Reset',
                            Icons.refresh,
                            selectedTag,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      selectedTag != null
                          ? 'Popular for $selectedTag'
                          : 'All Ambiences',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                filteredAmbiences.when(
                  data: (ambiences) {
                    if (ambiences.isEmpty) {
                      return SliverFillRemaining(
                        child: EmptyStateWidget(
                          message: 'No ambiences found',
                          icon: Icons.search_off,
                          buttonLabel: 'Clear Filters',
                          onButtonPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedTagProvider.notifier).state = null;
                          },
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final ambience = ambiences[index];
                          return AmbienceCard(
                            ambience: ambience,
                            onTap: () {
                              context.push('/ambience/${ambience.id}');
                            },
                          );
                        }, childCount: ambiences.length),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    child: EmptyStateWidget(
                      message: 'Failed to load ambiences',
                      icon: Icons.error_outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (sessionState.isSessionActive)
            MiniPlayer(onTap: () => context.push('/player')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String label,
    IconData icon,
    String? selected,
  ) {
    return TagFilterChip(
      label: label,
      icon: icon,
      isSelected: selected == label,
      onTap: () {
        final current = ref.read(selectedTagProvider);
        ref.read(selectedTagProvider.notifier).state = current == label
            ? null
            : label;
      },
    );
  }
}
