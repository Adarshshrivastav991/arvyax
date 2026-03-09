import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../../data/repositories/journal_repository.dart';

// All journal entries
final journalEntriesProvider = FutureProvider<List<JournalEntryModel>>((
  ref,
) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getAllEntries();
});

// Recent entries
final recentEntriesProvider = FutureProvider<List<JournalEntryModel>>((
  ref,
) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getRecent();
});

// Journal tab index
final journalTabProvider = StateProvider<int>((ref) => 0);

// Single entry by ID
final journalEntryByIdProvider =
    FutureProvider.family<JournalEntryModel?, String>((ref, id) async {
      final repo = ref.watch(journalRepositoryProvider);
      return repo.getEntryById(id);
    });

// Reflection state
class ReflectionState {
  final String text;
  final String? selectedMood;
  final bool isSaving;

  const ReflectionState({
    this.text = '',
    this.selectedMood,
    this.isSaving = false,
  });

  ReflectionState copyWith({
    String? text,
    String? selectedMood,
    bool? isSaving,
  }) {
    return ReflectionState(
      text: text ?? this.text,
      selectedMood: selectedMood ?? this.selectedMood,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ReflectionController extends StateNotifier<ReflectionState> {
  final JournalRepository _repo;

  ReflectionController(this._repo) : super(const ReflectionState());

  void updateText(String text) {
    state = state.copyWith(text: text);
  }

  void selectMood(String mood) {
    state = state.copyWith(selectedMood: mood);
  }

  Future<JournalEntryModel?> saveReflection({
    required String ambienceId,
    required String ambienceTitle,
    required String ambienceImage,
    required String ambienceTag,
    required int sessionDurationSeconds,
  }) async {
    if (state.text.trim().isEmpty && state.selectedMood == null) return null;

    state = state.copyWith(isSaving: true);

    final entry = JournalEntryModel(
      id: const Uuid().v4(),
      ambienceId: ambienceId,
      ambienceTitle: ambienceTitle,
      ambienceImage: ambienceImage,
      mood: state.selectedMood ?? 'Calm',
      reflectionText: state.text.trim(),
      createdAt: DateTime.now(),
      sessionDurationSeconds: sessionDurationSeconds,
      ambienceTag: ambienceTag,
    );

    await _repo.addEntry(entry);
    state = const ReflectionState();
    return entry;
  }

  void reset() {
    state = const ReflectionState();
  }
}

final reflectionControllerProvider =
    StateNotifierProvider<ReflectionController, ReflectionState>((ref) {
      final repo = ref.watch(journalRepositoryProvider);
      return ReflectionController(repo);
    });
