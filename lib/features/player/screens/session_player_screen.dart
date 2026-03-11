import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/session_controller.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  const SessionPlayerScreen({super.key});

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);

    // Navigate to reflection when session completes
    ref.listen<SessionState>(sessionControllerProvider, (prev, next) {
      if (next.isSessionComplete && !(prev?.isSessionComplete ?? false)) {
        if (next.ambience != null) {
          context.go('/reflection/${next.ambience!.id}');
        }
      }
    });

    if (state.ambience == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No active session'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  HapticSettingsNotifier.triggerHaptic();
                  context.go('/');
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final ambience = state.ambience!;

    return Scaffold(
      backgroundColor: _playerBg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticSettingsNotifier.triggerHaptic();
                      context.pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'NOW PLAYING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ArvyaX Session',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticSettingsNotifier.triggerHaptic();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.more_horiz_rounded, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Album art with breathing animation
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathAnimation.value,
                      child: child,
                    );
                  },
                  child: _buildAlbumArt(ambience.tag),
                ),
              ),
            ),

            // Title and level
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    ambience.title.replaceAll(ambience.tag, '').trim().isEmpty
                        ? 'Deep Breathing'
                        : ambience.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ambience.tag.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SessionProgressBar(
                elapsedSeconds: state.elapsedSeconds,
                totalSeconds: ambience.duration,
                onSeek: (value) {
                  final seekSeconds = (value * ambience.duration).round();
                  controller.seekTo(Duration(seconds: seekSeconds));
                },
              ),
            ),

            const SizedBox(height: 16),

            // Player controls
            PlayerControls(
              isPlaying: state.isPlaying,
              onPlayPause: controller.togglePlayPause,
              onSkipForward: controller.skipForward,
              onSkipBackward: controller.skipBackward,
            ),

            const SizedBox(height: 24),

            // Page dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == 0 ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == 0
                        ? AppColors.orange
                        : AppColors.textSecondaryLight.withValues(alpha: 0.25),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // End Session button
            GestureDetector(
              onTap: () {
                HapticSettingsNotifier.triggerHaptic();
                _showEndSessionDialog(context, controller);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  'END SESSION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(String tag) {
    final color = _tagColor(tag);
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.35),
            color.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.3, 0.65, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner glow
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Icon(
                _tagIcon(tag),
                size: 60,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndSessionDialog(
    BuildContext context,
    SessionController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Session?'),
        content: const Text(
          'Your progress will be saved and you can reflect on your experience.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticSettingsNotifier.triggerHaptic();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticSettingsNotifier.triggerHeavyHaptic();
              Navigator.of(ctx).pop();
              final ambience = ref.read(sessionControllerProvider).ambience;
              controller.endSession();
              if (ambience != null) {
                context.go('/reflection/${ambience.id}');
              }
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  Color _playerBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.playerBgDark : AppColors.playerBgLight;
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
}
