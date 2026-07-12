// ============================================================
// run_provider.dart — Runner Map
//
// Provider yang mengelola state dari sesi lari yang sedang aktif.
// Ini adalah "otak" dari fitur tracking aplikasi.
//
// [Session 6]  State Management dengan Provider / ChangeNotifier
//              - RunProvider extends ChangeNotifier
//              - Widget yang listen akan rebuild saat notifyListeners()
//              - Memisahkan business logic dari UI layer
// [Session 10] Penggunaan geolocator untuk mendapatkan posisi GPS
//              - LocationPermission request
//              - Stream<Position> untuk update real-time
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// [Session 6] ChangeNotifier memungkinkan widget untuk "subscribe"
// ke perubahan state melalui Consumer atau context.watch<RunProvider>()
class RunProvider extends ChangeNotifier {
  // ── State Variables ──────────────────────────────────────────

  // Status apakah sesi lari sedang aktif
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // Status pause
  bool _isPaused = false;
  bool get isPaused => _isPaused;

  // Timer untuk menghitung durasi
  Timer? _timer;
  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  // Jarak total dalam meter
  double _distanceMeters = 0.0;
  double get distanceKm => _distanceMeters / 1000.0;

  // Pace rata-rata (menit per km)
  double get avgPaceMinPerKm {
    if (distanceKm <= 0) return 0.0;
    final minutesElapsed = _elapsedSeconds / 60.0;
    return minutesElapsed / distanceKm;
  }

  // Daftar koordinat GPS yang sudah direkam (untuk polyline di peta)
  final List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  // Posisi terakhir user (untuk fokus kamera peta)
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  // Lap counter
  int _lapCount = 0;
  int get lapCount => _lapCount;

  // [Session 10] StreamSubscription untuk data GPS
  StreamSubscription<Position>? _positionSubscription;

  // Posisi sebelumnya, untuk menghitung jarak antar titik
  Position? _lastPosition;

  // ── Formatted Getters ────────────────────────────────────────

  // Format durasi menjadi HH:MM:SS
  String get formattedDuration {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Format pace menjadi "M:SS"
  String get formattedPace {
    final pace = avgPaceMinPerKm;
    if (pace <= 0 || pace.isInfinite || pace.isNaN) return '--:--';
    final totalSeconds = (pace * 60).round();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ── Public Methods ───────────────────────────────────────────

  // [Session 10] Meminta izin lokasi dari user dan memulai tracking
  Future<String?> startRun() async {
    // Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Layanan lokasi (GPS) tidak aktif. Aktifkan GPS terlebih dahulu.';
    }

    // [Session 10] Minta izin akses lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Izin lokasi ditolak. Mohon izinkan akses lokasi.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Izin lokasi diblokir permanen. Ubah di pengaturan aplikasi.';
    }

    // Reset semua data sebelum mulai
    _reset();
    _isRunning = true;
    _isPaused = false;

    // Mulai timer
    _startTimer();

    // [Session 10] Subscribe ke stream posisi GPS
    // LocationSettings mengatur akurasi dan interval update
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Akurasi tinggi untuk lari
      distanceFilter: 5,               // Update setiap 5 meter bergerak
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _onPositionUpdate(position);
      },
      onError: (error) {
        debugPrint('GPS Error: $error');
      },
    );

    notifyListeners();
    return null; // null berarti tidak ada error
  }

  // Toggle pause / resume
  void togglePause() {
    if (!_isRunning) return;

    _isPaused = !_isPaused;
    if (_isPaused) {
      _timer?.cancel();
      _positionSubscription?.pause();
    } else {
      _startTimer();
      _positionSubscription?.resume();
    }
    notifyListeners();
  }

  // Mark lap
  void markLap() {
    _lapCount++;
    notifyListeners();
  }

  // Selesai lari — kembalikan data untuk disimpan
  Map<String, dynamic> endRun() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _isRunning = false;
    _isPaused = false;

    final result = {
      'distanceKm': distanceKm,
      'durationSeconds': _elapsedSeconds,
      'avgPaceMinPerKm': avgPaceMinPerKm,
      'latitudes': _routePoints.map((p) => p.latitude).toList(),
      'longitudes': _routePoints.map((p) => p.longitude).toList(),
      'date': DateTime.now(),
    };

    notifyListeners();
    return result;
  }

  // ── Private Methods ──────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  // [Session 10] Dipanggil setiap kali ada posisi GPS baru
  void _onPositionUpdate(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);

    // Jika ada posisi sebelumnya, hitung jarak antara dua titik
    if (_lastPosition != null) {
      final double distance = _calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      // Hanya tambahkan jika jarak cukup signifikan (filter noise GPS)
      if (distance > 2) {
        _distanceMeters += distance;
        _routePoints.add(newPoint);
      }
    } else {
      // Titik pertama — langsung tambahkan
      _routePoints.add(newPoint);
    }

    _lastPosition = position;
    _currentPosition = newPoint;
    notifyListeners();
  }

  // [Session 10] Haversine formula — menghitung jarak antara dua
  // koordinat GPS dalam meter, digunakan karena bumi tidak datar
  double _calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meter
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRad(double deg) => deg * (pi / 180.0);

  void _reset() {
    _elapsedSeconds = 0;
    _distanceMeters = 0.0;
    _routePoints.clear();
    _lastPosition = null;
    _currentPosition = null;
    _lapCount = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
