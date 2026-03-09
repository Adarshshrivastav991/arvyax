import 'package:hive/hive.dart';

part 'journal_entry_model.g.dart';

@HiveType(typeId: 1)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ambienceId;

  @HiveField(2)
  final String ambienceTitle;

  @HiveField(3)
  final String ambienceImage;

  @HiveField(4)
  final String mood;

  @HiveField(5)
  final String reflectionText;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final int sessionDurationSeconds;

  @HiveField(8)
  final String ambienceTag;

  JournalEntryModel({
    required this.id,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.ambienceImage,
    required this.mood,
    required this.reflectionText,
    required this.createdAt,
    required this.sessionDurationSeconds,
    required this.ambienceTag,
  });
}
