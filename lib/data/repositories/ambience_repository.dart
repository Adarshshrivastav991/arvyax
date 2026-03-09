import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ambience_model.dart';

final ambienceRepositoryProvider = Provider<AmbienceRepository>((ref) {
  return AmbienceRepository();
});

class AmbienceRepository {
  List<AmbienceModel>? _cache;

  Future<List<AmbienceModel>> loadAmbiences() async {
    if (_cache != null) return _cache!;
    final jsonString = await rootBundle.loadString(
      'assets/data/ambiences.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _cache = jsonList
        .map((e) => AmbienceModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<AmbienceModel?> getAmbienceById(String id) async {
    final ambiences = await loadAmbiences();
    try {
      return ambiences.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
