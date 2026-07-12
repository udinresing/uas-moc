// ============================================================
// save_run_screen.dart — Runner Map
//
// Halaman untuk menyimpan sesi lari setelah selesai.
// User bisa memberikan nama/judul untuk sesi larinya.
//
// [Session 4] StatefulWidget — mengelola TextEditingController
// [Session 5] Form & TextFormField dengan validasi input
// [Session 7] Menerima data (Map) dari ActiveRunScreen
// [Session 12] Menyimpan RunSession ke Hive local database
// ============================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/run_session.dart';
import '../utils/constants.dart';
import '../widgets/run_info_card.dart';
import 'home_screen.dart';

class SaveRunScreen extends StatefulWidget {
  // [Session 7] Data dikirim dari ActiveRunScreen via constructor
  final Map<String, dynamic> runData;

  const SaveRunScreen({super.key, required this.runData});

  @override
  State<SaveRunScreen> createState() => _SaveRunScreenState();
}

class _SaveRunScreenState extends State<SaveRunScreen> {
  // [Session 5] GlobalKey untuk mengakses Form state (validasi)
  final _formKey = GlobalKey<FormState>();

  // [Session 4] TextEditingController untuk mengambil input teks
  final _titleController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    // [Session 4] Selalu dispose controller untuk mencegah memory leak
    _titleController.dispose();
    super.dispose();
  }

  // Menyimpan data lari ke Hive
  Future<void> _saveRun() async {
    // [Session 5] Validasi form sebelum menyimpan
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // [Session 7] Ambil data dari Map yang diterima
    final distanceKm = widget.runData['distanceKm'] as double;
    final durationSeconds = widget.runData['durationSeconds'] as int;
    final avgPaceMinPerKm = widget.runData['avgPaceMinPerKm'] as double;
    final date = widget.runData['date'] as DateTime;
    final latitudes = List<double>.from(widget.runData['latitudes'] as List);
    final longitudes = List<double>.from(widget.runData['longitudes'] as List);

    // [Session 12] Buat objek RunSession dan simpan ke Hive
    final session = RunSession(
      title: _titleController.text.trim(),
      distanceKm: distanceKm,
      durationSeconds: durationSeconds,
      avgPaceMinPerKm: avgPaceMinPerKm,
      date: date,
      latitudes: latitudes,
      longitudes: longitudes,
    );

    // Akses box Hive dan tambahkan data
    final box = Hive.box<RunSession>('run_sessions');
    await box.add(session);

    setState(() => _isSaving = false);

    if (mounted) {
      // [Session 5] Kembali ke HomeScreen setelah simpan
      // pushAndRemoveUntil menghapus semua rute sebelumnya dari stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data untuk ditampilkan di preview
    final distanceKm = widget.runData['distanceKm'] as double? ?? 0.0;
    final durationSeconds = widget.runData['durationSeconds'] as int? ?? 0;

    // Format durasi
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    final durationStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    // Format pace
    final pace = widget.runData['avgPaceMinPerKm'] as double? ?? 0.0;
    String paceStr = '--:--';
    if (pace > 0 && !pace.isInfinite) {
      final totalSec = (pace * 60).round();
      paceStr = '${totalSec ~/ 60}:${(totalSec % 60).toString().padLeft(2, '0')}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Tidak ada back button
        title: const Text(
          'Simpan Lari',
          style: AppTextStyles.pageTitle,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header selamat
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orange, AppColors.orangeDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Lari Selesai! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Berikut ringkasan sesi lari Anda',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Summary stats
              LargeDistanceCard(
                distance: distanceKm.toStringAsFixed(2),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RunInfoCard(
                      label: 'Total Time',
                      value: durationStr,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RunInfoCard(
                      label: 'Avg Pace',
                      value: paceStr,
                      suffix: '/km',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // [Session 5] Input nama sesi lari
              const Text(
                'Nama Sesi Lari',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // [Session 5] TextFormField dengan validasi
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Pagi di Taman, Sore Santai...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.orange, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                // [Session 5] Validasi: tidak boleh kosong
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama sesi tidak boleh kosong';
                  }
                  return null; // null = valid
                },
              ),

              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRun,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'SIMPAN',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),

              // Tombol Buang (tidak simpan)
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Buang & Kembali ke Beranda',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
