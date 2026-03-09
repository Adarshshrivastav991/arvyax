import 'package:hive/hive.dart';

part 'ambience_model.g.dart';

@HiveType(typeId: 0)
class AmbienceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String tag;

  @HiveField(3)
  final int duration;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String image;

  @HiveField(6)
  final String audio;

  @HiveField(7)
  final List<String> recipe;

  AmbienceModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.duration,
    required this.description,
    required this.image,
    required this.audio,
    required this.recipe,
  });

  factory AmbienceModel.fromJson(Map<String, dynamic> json) {
    return AmbienceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      duration: json['duration'] as int,
      description: json['description'] as String,
      image: json['image'] as String,
      audio: json['audio'] as String,
      recipe: List<String>.from(json['recipe'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tag': tag,
      'duration': duration,
      'description': description,
      'image': image,
      'audio': audio,
      'recipe': recipe,
    };
  }
}
