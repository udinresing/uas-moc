// ============================================================
// active_run_screen.dart — Runner Map
//
// Halaman utama saat user sedang berlari. Ini adalah tampilan
// yang sesuai dengan desain pada file PNG yang diberikan.
//
// [Session 4] StatefulWidget — mengelola status navigasi
// [Session 5] Layout kompleks: Column, Stack, Expanded
// [Session 6] Consumer<RunProvider> — reactive UI dari Provider
// [Session 10] flutter_map + PolylineLayer untuk tracking GPS
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/run_provider.dart';
import '../utils/constants.dart';
import '../widgets/run_info_card.dart';
import 'save_run_screen.dart';

class ActiveRunScreen extends StatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  // [Session 5] MapController untuk mengontrol kamera peta secara programatik
  final MapController _mapController = MapController();
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    // Mulai sesi lari segera setelah layar terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRun();
    });
  }

  Future<void> _startRun() async {
    final provider = context.read<RunProvider>();
    final error = await provider.startRun();
    if (error != null && mounted) {
      // Tampilkan error jika GPS tidak tersedia
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() => _isStarted = true);
    }
  }

  // Dipanggil saat tombol "END RUN" ditekan
  void _onEndRun() {
    // [Session 5] Dialog konfirmasi sebelum mengakhiri sesi
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Akhiri Lari?',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.textDark)),
        content: const Text(
          'Data lari Anda akan disimpan ke riwayat.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Lanjut',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              final provider = context.read<RunProvider>();
              final runData = provider.endRun(); // Dapatkan data lari

              // [Session 5] Navigasi ke SaveRunScreen dengan data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SaveRunScreen(runData: runData),
                ),
              );
            },
            child: const Text('Akhiri',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── App Bar ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark),
          onPressed: () {
            // Jika berlari, tanya konfirmasi dulu
            if (_isStarted) {
              _onEndRun();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Active Run', style: AppTextStyles.pageTitle),
      ),

      // ── Body ─────────────────────────────────────────────────
      body: _isStarted
          ? _buildRunningUI()
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.orange),
                  SizedBox(height: 16),
                  Text('Menghubungkan GPS...',
                      style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
    );
  }

  Widget _buildRunningUI() {
    // [Session 6] Consumer merebuild hanya bagian ini ketika state berubah
    return Consumer<RunProvider>(
      builder: (context, provider, _) {
        // Gerakkan kamera peta ke posisi terkini
        if (provider.currentPosition != null) {
          try {
            _mapController.move(provider.currentPosition!, 17.0);
          } catch (_) {}
        }

        return Column(
          children: [
            // Padding dan konten stats + peta
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Kartu TOTAL DISTANCE ──────────────────
                    LargeDistanceCard(
                      distance: provider.distanceKm.toStringAsFixed(2),
                    ),
                    const SizedBox(height: 12),

                    // ── Kartu TOTAL TIME & AVG PACE (berdampingan)
                    Row(
                      children: [
                        Expanded(
                          child: RunInfoCard(
                            label: 'Total Time',
                            value: provider.formattedDuration,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RunInfoCard(
                            label: 'Avg Pace',
                            value: provider.formattedPace,
                            suffix: '/km',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Peta dengan tracking line ─────────────
                    // [Session 10] flutter_map dengan PolylineLayer
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.cardBorder, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Peta OpenStreetMap
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              // Posisi default: Jakarta
                              initialCenter: provider.currentPosition ??
                                  const LatLng(-6.2088, 106.8456),
                              initialZoom: 17.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all,
                              ),
                            ),
                            children: [
                              // Layer tile peta (OpenStreetMap)
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.runner_map',
                              ),

                              // [Session 10] Layer garis tracking berwarna orange
                              if (provider.routePoints.length > 1)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: provider.routePoints,
                                      color: AppColors.trackLine,
                                      strokeWidth: 5.0,
                                    ),
                                  ],
                                ),

                              // Titik posisi terkini user
                              if (provider.currentPosition != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: provider.currentPosition!,
                                      width: 24,
                                      height: 24,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.orange,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.orange
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // ── Tombol Pause/Play di tengah bawah peta
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: provider.togglePause,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.orange,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.orange.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    provider.isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Badge lap jika ada lap
                          if (provider.lapCount > 0)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Lap ${provider.lapCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tombol bawah: MARK LAP & END RUN ─────────────
            // Persis seperti desain PNG
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    // Tombol MARK LAP
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.markLap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        icon: const Icon(Icons.flag_rounded, size: 20),
                        label: const Text(
                          'MARK LAP',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol END RUN
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onEndRun,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        icon: const Icon(Icons.sports_score_rounded, size: 20),
                        label: const Text(
                          'END RUN',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
