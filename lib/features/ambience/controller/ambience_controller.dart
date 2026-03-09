import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience_model.dart';
import '../../../data/repositories/ambience_repository.dart';

// All ambiences loaded from JSON
final ambiencesProvider = FutureProvider<List<AmbienceModel>>((ref) async {
  final repo = ref.watch(ambienceRepositoryProvider);
  return repo.loadAmbiences();
});

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected tag filter
final selectedTagProvider = StateProvider<String?>((ref) => null);

// Filtered ambiences
final filteredAmbiencesProvider = Provider<AsyncValue<List<AmbienceModel>>>((
  ref,
) {
  final ambiencesAsync = ref.watch(ambiencesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final tag = ref.watch(selectedTagProvider);

  return ambiencesAsync.whenData((ambiences) {
    var result = ambiences;

    if (tag != null && tag.isNotEmpty) {
      result = result.where((a) => a.tag == tag).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.description.toLowerCase().contains(query) ||
            a.tag.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  });
});

// Get ambience by ID
final ambienceByIdProvider = FutureProvider.family<AmbienceModel?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(ambienceRepositoryProvider);
  return repo.getAmbienceById(id);
});
