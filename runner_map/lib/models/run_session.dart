// ============================================================
// run_session.dart — Runner Map
//
// Model data untuk satu sesi lari yang telah selesai.
//
// [Session 4]  Dart class & konstruktor
// [Session 7]  JSON serialization (toJson/fromJson) untuk data flow
// [Session 12] Hive TypeAdapter — memungkinkan objek ini disimpan
//              langsung ke database lokal Hive tanpa konversi manual
// ============================================================

import 'package:hive/hive.dart';

// [Session 12] part directive — diperlukan oleh build_runner untuk
// men-generate file run_session.g.dart (TypeAdapter otomatis)
part 'run_session.g.dart';

// [Session 12] @HiveType menandai class ini sebagai Hive object
// typeId harus unik untuk setiap Hive type dalam satu aplikasi
@HiveType(typeId: 0)
class RunSession extends HiveObject {
  // [Session 12] @HiveField — setiap field yang ingin disimpan
  // diberi nomor index unik (tidak boleh diubah setelah data tersimpan)

  @HiveField(0)
  final String title;

  @HiveField(1)
  final double distanceKm;    // Total jarak dalam kilometer

  @HiveField(2)
  final int durationSeconds;  // Total durasi dalam detik

  @HiveField(3)
  final double avgPaceMinPerKm; // Pace rata-rata (menit per km)

  @HiveField(4)
  final DateTime date;        // Tanggal dan waktu sesi

  @HiveField(5)
  final List<double> latitudes;  // Koordinat GPS: latitude

  @HiveField(6)
  final List<double> longitudes; // Koordinat GPS: longitude

  // [Session 4] Konstruktor dengan named parameters
  RunSession({
    required this.title,
    required this.distanceKm,
    required this.durationSeconds,
    required this.avgPaceMinPerKm,
    required this.date,
    required this.latitudes,
    required this.longitudes,
  });

  // [Session 7] toJson — mengubah objek menjadi Map<String, dynamic>
  // Berguna untuk debugging dan potensi integrasi API di masa depan
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'distanceKm': distanceKm,
      'durationSeconds': durationSeconds,
      'avgPaceMinPerKm': avgPaceMinPerKm,
      'date': date.toIso8601String(),
      'latitudes': latitudes,
      'longitudes': longitudes,
    };
  }

  // [Session 7] fromJson — membuat objek dari Map (factory constructor)
  factory RunSession.fromJson(Map<String, dynamic> json) {
    return RunSession(
      title: json['title'] as String,
      distanceKm: json['distanceKm'] as double,
      durationSeconds: json['durationSeconds'] as int,
      avgPaceMinPerKm: json['avgPaceMinPerKm'] as double,
      date: DateTime.parse(json['date'] as String),
      latitudes: List<double>.from(json['latitudes'] as List),
      longitudes: List<double>.from(json['longitudes'] as List),
    );
  }

  // [Session 4] Getter untuk menampilkan durasi dalam format HH:MM:SS
  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // [Session 4] Getter untuk format pace "M:SS /km"
  String get formattedPace {
    if (avgPaceMinPerKm <= 0 || avgPaceMinPerKm.isInfinite) return '--:--';
    final totalSeconds = (avgPaceMinPerKm * 60).round();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
