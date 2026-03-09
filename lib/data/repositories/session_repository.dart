import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

class SessionRepository {
  static const String _boxName = 'session_state';

  Future<Box<dynamic>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return Hive.openBox<dynamic>(_boxName);
    }
    return Hive.box<dynamic>(_boxName);
  }

  Future<void> saveActiveSession({
    required String ambienceId,
    required int elapsedSeconds,
    required bool isPlaying,
  }) async {
    final box = await _getBox();
    await box.put('active_ambience_id', ambienceId);
    await box.put('elapsed_seconds', elapsedSeconds);
    await box.put('is_playing', isPlaying);
    await box.put('saved_at', DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    final box = await _getBox();
    final ambienceId = box.get('active_ambience_id');
    if (ambienceId == null) return null;
    return {
      'ambienceId': ambienceId as String,
      'elapsedSeconds': box.get('elapsed_seconds', defaultValue: 0) as int,
      'isPlaying': box.get('is_playing', defaultValue: false) as bool,
    };
  }

  Future<void> clearActiveSession() async {
    final box = await _getBox();
    await box.clear();
  }
}
