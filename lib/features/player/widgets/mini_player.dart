import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/session_controller.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isSessionActive || state.ambience == null) {
      return const SizedBox.shrink();
    }

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
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 50),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 6),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              _tagColor(
                                state.ambience!.tag,
                              ).withValues(alpha: 0.4),
                              _tagColor(
                                state.ambience!.tag,
                              ).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Icon(
                          _tagIcon(state.ambience!.tag),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.ambience!.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Ambient sounds',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 22),
                        onPressed: () {},
                        color: AppColors.textSecondaryLight,
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticSettingsNotifier.triggerHeavyHaptic();
                          ref
                              .read(sessionControllerProvider.notifier)
                              .togglePlayPause();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 22),
                        onPressed: () {},
                        color: AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: state.progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.textSecondaryLight.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.orange,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
}
