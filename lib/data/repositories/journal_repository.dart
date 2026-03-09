import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry_model.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

class JournalRepository {
  static const String _boxName = 'journal_entries';

  Future<Box<JournalEntryModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return Hive.openBox<JournalEntryModel>(_boxName);
    }
    return Hive.box<JournalEntryModel>(_boxName);
  }

  Future<List<JournalEntryModel>> getAllEntries() async {
    final box = await _getBox();
    final entries = box.values.toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<void> addEntry(JournalEntryModel entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<JournalEntryModel?> getEntryById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<List<JournalEntryModel>> getFavorites() async {
    final entries = await getAllEntries();
    return entries;
  }

  Future<List<JournalEntryModel>> getRecent() async {
    final entries = await getAllEntries();
    final now = DateTime.now();
    return entries
        .where((e) => now.difference(e.createdAt).inDays <= 7)
        .toList();
  }
}
