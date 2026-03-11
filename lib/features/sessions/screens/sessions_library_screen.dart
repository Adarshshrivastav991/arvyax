import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/ambience_model.dart';
import '../../ambience/controller/ambience_controller.dart';
import '../../player/controller/session_controller.dart';
import '../../player/widgets/mini_player.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/utils/time_formatter.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class SessionsLibraryScreen extends ConsumerWidget {
  const SessionsLibraryScreen({super.key});

  static const _moodCategories = [
    _MoodCategory(
      'Focus',
      'Deep concentration & flow',
      Icons.flare_rounded,
      AppColors.focusTag,
      LinearGradient(
        colors: [Color(0xFFE8652B), Color(0xFFFF8A65)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _MoodCategory(
      'Calm',
      'Peaceful relaxation',
      Icons.water_drop_rounded,
      AppColors.calmTag,
      LinearGradient(
        colors: [Color(0xFF6B8E7B), Color(0xFF81C784)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _MoodCategory(
      'Sleep',
      'Restful soundscapes',
      Icons.nights_stay_rounded,
      AppColors.sleepTag,
      LinearGradient(
        colors: [Color(0xFF5B6AAF), Color(0xFF7986CB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _MoodCategory(
      'Reset',
      'Refresh & recharge',
      Icons.refresh_rounded,
      AppColors.resetTag,
      LinearGradient(
        colors: [Color(0xFFD4A017), Color(0xFFFFD54F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambiencesAsync = ref.watch(ambiencesProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Premium header
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    title: Text(
                      'Sound Library',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  AppColors.orange.withValues(alpha: 0.15),
                                  AppColors.backgroundDark.withValues(
                                    alpha: 0.0,
                                  ),
                                ]
                              : [
                                  AppColors.orange.withValues(alpha: 0.08),
                                  AppColors.backgroundLight.withValues(
                                    alpha: 0.0,
                                  ),
                                ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 60),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Explore by Mood',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.orange.withValues(
                                          alpha: 0.9,
                                        ),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Choose how you want to feel',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                child: Icon(
                                  Icons.headphones_rounded,
                                  color: AppColors.orange,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Mood category cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moodCategories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final mood = _moodCategories[index];
                          return _MoodCategoryCard(
                            category: mood,
                            isDark: isDark,
                            onTap: () {
                              HapticSettingsNotifier.triggerHaptic();
                              _scrollToSection(context, mood.label);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Ambience sections by mood
                ambiencesAsync.when(
                  data: (ambiences) {
                    final sections = <Widget>[];
                    for (final mood in _moodCategories) {
                      final moodAmbiences = ambiences
                          .where((a) => a.tag == mood.label)
                          .toList();
                      if (moodAmbiences.isEmpty) continue;
                      sections.add(
                        _buildMoodSection(
                          context,
                          ref,
                          mood,
                          moodAmbiences,
                          isDark,
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildListDelegate(sections),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('Failed to load: $e')),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          if (sessionState.isSessionActive)
            MiniPlayer(onTap: () => context.push('/player')),
        ],
      ),
    );
  }

  void _scrollToSection(BuildContext context, String label) {
    // Scroll handled by tapping category - navigates to first ambience
  }

  Widget _buildMoodSection(
    BuildContext context,
    WidgetRef ref,
    _MoodCategory mood,
    List<AmbienceModel> ambiences,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mood.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(mood.icon, color: mood.color, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.label,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                    Text(
                      mood.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${ambiences.length} sessions',
                  style: TextStyle(
                    fontSize: 12,
                    color: mood.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Horizontal list of session cards
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: ambiences.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _LibrarySessionCard(
                  ambience: ambiences[index],
                  moodColor: mood.color,
                  moodGradient: mood.gradient,
                  isDark: isDark,
                  onTap: () {
                    HapticSettingsNotifier.triggerHaptic();
                    context.push('/ambience/${ambiences[index].id}');
                  },
                  onPlay: () {
                    HapticSettingsNotifier.triggerHeavyHaptic();
                    ref
                        .read(sessionControllerProvider.notifier)
                        .startSession(ambiences[index]);
                    context.push('/player');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Supporting Widgets ---

class _MoodCategory {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _MoodCategory(
    this.label,
    this.subtitle,
    this.icon,
    this.color,
    this.gradient,
  );
}

class _MoodCategoryCard extends StatefulWidget {
  final _MoodCategory category;
  final bool isDark;
  final VoidCallback onTap;

  const _MoodCategoryCard({
    required this.category,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_MoodCategoryCard> createState() => _MoodCategoryCardState();
}

class _MoodCategoryCardState extends State<_MoodCategoryCard>
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
    final mood = widget.category;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: Container(
            width: 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: mood.gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: mood.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(mood.icon, color: Colors.white, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mood.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibrarySessionCard extends StatefulWidget {
  final AmbienceModel ambience;
  final Color moodColor;
  final Gradient moodGradient;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _LibrarySessionCard({
    required this.ambience,
    required this.moodColor,
    required this.moodGradient,
    required this.isDark,
    required this.onTap,
    required this.onPlay,
  });

  @override
  State<_LibrarySessionCard> createState() => _LibrarySessionCardState();
}

class _LibrarySessionCardState extends State<_LibrarySessionCard>
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
      end: 0.95,
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
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: Container(
            width: 165,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.moodColor.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient art area
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: widget.moodGradient),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _tagIcon(widget.ambience.tag),
                          size: 36,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      // Duration badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            TimeFormatter.formatMinutesShort(
                              widget.ambience.duration,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // Play button
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: widget.onPlay,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: widget.moodColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info section
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ambience.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.ambience.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _tagIcon(String tag) {
    switch (tag) {
      case 'Focus':
        return Icons.flare_rounded;
      case 'Calm':
        return Icons.water_drop_rounded;
      case 'Sleep':
        return Icons.nights_stay_rounded;
      case 'Reset':
        return Icons.refresh_rounded;
      default:
        return Icons.flare_rounded;
    }
  }
}
