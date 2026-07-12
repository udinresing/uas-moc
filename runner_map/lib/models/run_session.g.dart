// GENERATED CODE - DO NOT MODIFY BY HAND
// ============================================================
// run_session.g.dart
//
// [Session 12] File ini di-generate oleh build_runner + hive_generator
// berdasarkan anotasi @HiveType dan @HiveField di run_session.dart.
// TypeAdapter ini mengajarkan Hive cara menyimpan & membaca RunSession.
// ============================================================

part of 'run_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunSessionAdapter extends TypeAdapter<RunSession> {
  @override
  final int typeId = 0;

  @override
  RunSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RunSession(
      title: fields[0] as String,
      distanceKm: fields[1] as double,
      durationSeconds: fields[2] as int,
      avgPaceMinPerKm: fields[3] as double,
      date: fields[4] as DateTime,
      latitudes: (fields[5] as List).cast<double>(),
      longitudes: (fields[6] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, RunSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.distanceKm)
      ..writeByte(2)
      ..write(obj.durationSeconds)
      ..writeByte(3)
      ..write(obj.avgPaceMinPerKm)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.latitudes)
      ..writeByte(6)
      ..write(obj.longitudes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
