import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../../data/repositories/journal_repository.dart';
import '../controller/journal_controller.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class JournalCard extends ConsumerStatefulWidget {
  final JournalEntryModel entry;
  final VoidCallback onTap;

  const JournalCard({super.key, required this.entry, required this.onTap});

  @override
  ConsumerState<JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends ConsumerState<JournalCard>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, h:mm a');
    final tagColor = _tagColor(widget.entry.ambienceTag);

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
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.06),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.75),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.95),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: tagColor.withValues(alpha: isDark ? 0.08 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image header
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tagColor.withValues(alpha: 0.4),
                        tagColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Subtle radial effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.4, -0.4),
                              radius: 1.5,
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          _tagIcon(widget.entry.ambienceTag),
                          size: 44,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${dateFormat.format(widget.entry.createdAt)} — ${widget.entry.ambienceTitle}',
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticSettingsNotifier.triggerHaptic();
                              ref
                                  .read(journalRepositoryProvider)
                                  .toggleFavorite(widget.entry.id);
                              ref.invalidate(journalEntriesProvider);
                            },
                            child: widget.entry.isFavorite
                                ? const Icon(
                                    Icons.favorite,
                                    color: AppColors.orange,
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    size: 20,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MOOD: ${widget.entry.mood.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (widget.entry.reflectionText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '"${widget.entry.reflectionText}"',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondaryLight,
                                height: 1.5,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.entry.sessionDurationSeconds ~/ 60} min Session',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.orange,
                                  AppColors.orangeLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orange.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: const Text(
                              'View Session',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
