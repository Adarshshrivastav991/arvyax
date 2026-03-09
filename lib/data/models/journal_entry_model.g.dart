// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_model.dart';

class JournalEntryModelAdapter extends TypeAdapter<JournalEntryModel> {
  @override
  final int typeId = 1;

  @override
  JournalEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return JournalEntryModel(
      id: fields[0] as String,
      ambienceId: fields[1] as String,
      ambienceTitle: fields[2] as String,
      ambienceImage: fields[3] as String,
      mood: fields[4] as String,
      reflectionText: fields[5] as String,
      createdAt: fields[6] as DateTime,
      sessionDurationSeconds: fields[7] as int,
      ambienceTag: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntryModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ambienceId)
      ..writeByte(2)
      ..write(obj.ambienceTitle)
      ..writeByte(3)
      ..write(obj.ambienceImage)
      ..writeByte(4)
      ..write(obj.mood)
      ..writeByte(5)
      ..write(obj.reflectionText)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.sessionDurationSeconds)
      ..writeByte(8)
      ..write(obj.ambienceTag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
