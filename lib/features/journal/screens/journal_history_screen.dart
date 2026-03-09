import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controller/journal_controller.dart';
import '../widgets/journal_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/theme/colors.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final selectedTab = ref.watch(journalTabProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Journal'),
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                _buildTab(context, ref, 'All', 0, selectedTab),
                const SizedBox(width: 24),
                _buildTab(context, ref, 'Recent', 1, selectedTab),
                const SizedBox(width: 24),
                _buildTab(context, ref, 'Favorites', 2, selectedTab),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No reflections yet.\nStart a session to begin.',
                    icon: Icons.book_outlined,
                  );
                }

                // Filter based on tab
                final filtered = selectedTab == 1
                    ? entries
                          .where(
                            (e) =>
                                DateTime.now().difference(e.createdAt).inDays <=
                                7,
                          )
                          .toList()
                    : entries;

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No entries in this category.',
                    icon: Icons.inbox_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return JournalCard(
                      entry: entry,
                      onTap: () => context.push('/journal/${entry.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyStateWidget(
                message: 'Failed to load journal entries',
                icon: Icons.error_outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    WidgetRef ref,
    String label,
    int index,
    int selected,
  ) {
    final isSelected = selected == index;
    return GestureDetector(
      onTap: () => ref.read(journalTabProvider.notifier).state = index,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.orange
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Container(
            height: 2,
            width: 30,
            color: isSelected ? AppColors.orange : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
