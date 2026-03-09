import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controller/journal_controller.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/utils/time_formatter.dart';
import '../../../shared/providers/haptic_settings_provider.dart';

class JournalDetailScreen extends ConsumerWidget {
  final String entryId;

  const JournalDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(journalEntryByIdProvider(entryId));

    return Scaffold(
      body: entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }

          final dateFormat = DateFormat('MMMM d, y • h:mm a');
          final tagColor = _tagColor(entry.ambienceTag);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    HapticSettingsNotifier.triggerHaptic();
                    context.pop();
                  },
                ),
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                    child: Center(
                      child: Icon(
                        _tagIcon(entry.ambienceTag),
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'SESSION DETAIL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood and date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _moodColor(entry.mood),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _moodIcon(entry.mood),
                                  size: 14,
                                  color: AppColors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.mood.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.orange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dateFormat.format(entry.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        entry.ambienceTitle,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),

                      const SizedBox(height: 4),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Reflection text
                      if (entry.reflectionText.isNotEmpty)
                        Text(
                          entry.reflectionText,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.8,
                                color: AppColors.textSecondaryLight,
                              ),
                        ),

                      const SizedBox(height: 32),

                      // Session stats
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SESSION STATS',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DURATION',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.orange,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              letterSpacing: 0.8,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        TimeFormatter.formatMinutesLong(
                                          entry.sessionDurationSeconds,
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FOCUS SCORE',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.orange,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              letterSpacing: 0.8,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(80 + (entry.sessionDurationSeconds % 20)).clamp(75, 99)}%',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Edit button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            HapticSettingsNotifier.triggerHaptic();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(color: AppColors.orange),
                            ),
                          ),
                          child: const Text(
                            'Edit Journal Entry',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: Text(
                          'ArvyaX Sessions Journal • © ${DateTime.now().year}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondaryLight.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                        ),
                      ),
                    ],
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

  Color _moodColor(String mood) {
    switch (mood) {
      case 'Calm':
        return AppColors.moodCalm;
      case 'Grounded':
        return AppColors.moodGrounded;
      case 'Energized':
        return AppColors.moodEnergized;
      case 'Sleepy':
        return AppColors.moodSleepy;
      default:
        return AppColors.moodCalm;
    }
  }

  IconData _moodIcon(String mood) {
    switch (mood) {
      case 'Calm':
        return Icons.spa;
      case 'Grounded':
        return Icons.landscape;
      case 'Energized':
        return Icons.bolt;
      case 'Sleepy':
        return Icons.dark_mode;
      default:
        return Icons.spa;
    }
  }
}
