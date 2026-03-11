import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/journal_controller.dart';
import '../widgets/mood_selector.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/providers/haptic_settings_provider.dart';
import '../../ambience/controller/ambience_controller.dart';
import '../../player/controller/session_controller.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  final String ambienceId;

  const ReflectionScreen({super.key, required this.ambienceId});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(widget.ambienceId));
    final reflectionState = ref.watch(reflectionControllerProvider);
    final sessionState = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticSettingsNotifier.triggerHaptic();
            context.go('/');
          },
        ),
        title: const Text('Reflection'),
      ),
      body: ambienceAsync.when(
        data: (ambience) {
          if (ambience == null) {
            return const Center(child: Text('Ambience not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is gently present with you right now?',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(height: 1.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'ArvyaX Session Reflection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _textController,
                        maxLines: 8,
                        onChanged: (value) {
                          ref
                              .read(reflectionControllerProvider.notifier)
                              .updateText(value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Start writing your reflection...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Text(
                          'Shared only with you',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondaryLight.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'HOW ARE YOU FEELING?',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                MoodSelector(
                  selectedMood: reflectionState.selectedMood,
                  onMoodSelected: (mood) {
                    ref
                        .read(reflectionControllerProvider.notifier)
                        .selectMood(mood);
                  },
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  label: 'Save Reflection',
                  icon: Icons.check,
                  isLoading: reflectionState.isSaving,
                  onPressed: () async {
                    final entry = await ref
                        .read(reflectionControllerProvider.notifier)
                        .saveReflection(
                          ambienceId: ambience.id,
                          ambienceTitle: ambience.title,
                          ambienceImage: ambience.image,
                          ambienceTag: ambience.tag,
                          sessionDurationSeconds:
                              sessionState.elapsedSeconds > 0
                              ? sessionState.elapsedSeconds
                              : ambience.duration,
                        );

                    if (entry != null && context.mounted) {
                      ref
                          .read(sessionControllerProvider.notifier)
                          .clearSession();
                      ref.invalidate(journalEntriesProvider);
                      context.go('/journal');
                    }
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Your entry will be saved to your private journal.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
