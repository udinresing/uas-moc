// ============================================================
// home_screen.dart — Runner Map
//
// Halaman utama aplikasi. Menampilkan daftar riwayat lari
// dan tombol untuk memulai sesi lari baru.
//
// [Session 4] StatefulWidget — menyimpan state list riwayat
// [Session 5] Layout: Scaffold, AppBar, ListView.builder
//             BottomNavigationBar pattern diganti dengan
//             FloatingActionButton sebagai aksi utama
// [Session 12] Membaca data dari Hive Box
// ============================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/run_session.dart';
import '../utils/constants.dart';
import '../widgets/history_tile.dart';
import 'active_run_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── App Bar ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Runner Map',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: AppColors.orange,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.orange.withValues(alpha: 0.15),
              radius: 20,
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.orange),
            ),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      // [Session 12] ValueListenableBuilder merebuild widget secara otomatis
      // setiap kali data di Hive Box berubah (tanpa perlu setState manual)
      body: ValueListenableBuilder<Box<RunSession>>(
        valueListenable: Hive.box<RunSession>('run_sessions').listenable(),
        builder: (context, box, _) {
          // Ambil semua session dan urutkan terbaru di atas
          final sessions = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          // Jika belum ada riwayat, tampilkan empty state
          if (sessions.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary di bagian atas
              _buildSummaryHeader(sessions),

              // Header daftar riwayat
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Riwayat Lari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              // [Session 5] ListView.builder untuk performa optimal
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return HistoryTile(session: sessions[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),

      // ── FAB: Mulai Lari ──────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // [Session 5] Navigasi ke ActiveRunScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActiveRunScreen()),
          );
        },
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text(
          'Mulai Lari',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSummaryHeader(List<RunSession> sessions) {
    final totalKm = sessions.fold<double>(0, (sum, s) => sum + s.distanceKm);
    final totalRuns = sessions.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.orange, AppColors.orangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Total Lari', '$totalRuns', 'sesi'),
          Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.3)),
          _buildStat('Total Jarak', totalKm.toStringAsFixed(2), 'km'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_run_rounded,
              size: 80, color: AppColors.orange.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat lari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tekan tombol "Mulai Lari" untuk memulai!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
