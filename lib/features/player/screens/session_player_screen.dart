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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 30),
                    onPressed: () {
                      HapticSettingsNotifier.triggerHaptic();
                      context.pop();
                    },
                  ),
                  Column(
                    children: [
                      Text(
                        'NOW PLAYING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ArvyaX Session',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      HapticSettingsNotifier.triggerHaptic();
                    },
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    ambience.title.replaceAll(ambience.tag, '').trim().isEmpty
                        ? 'Deep Breathing'
                        : ambience.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Level 1 • Focused Clarity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == 0
                        ? AppColors.textPrimaryLight.withValues(alpha: 0.6)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // End Session button
            TextButton(
              onPressed: () {
                HapticSettingsNotifier.triggerHaptic();
                _showEndSessionDialog(context, controller);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Text(
                'END SESSION',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
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
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          stops: const [0.4, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.4),
                color.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            _tagIcon(tag),
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
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
