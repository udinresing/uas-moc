// ============================================================
// main.dart — Runner Map
//
// Entry point aplikasi. Bertanggung jawab untuk:
//   1. Inisialisasi Hive (local database)
//   2. Registrasi Hive TypeAdapter
//   3. Membuka Hive Box
//   4. Menyiapkan Provider (state management)
//   5. Menjalankan aplikasi
//
// Struktur Proyek:
//   lib/
//     main.dart
//     models/
//       run_session.dart        ← Hive model (Session 7, 12)
//       run_session.g.dart      ← Auto-generated TypeAdapter (Session 12)
//     providers/
//       run_provider.dart       ← State management GPS & Timer (Session 6, 10)
//     screens/
//       home_screen.dart        ← Daftar riwayat lari (Session 4, 5, 12)
//       active_run_screen.dart  ← Tampilan saat berlari + peta (Session 5, 6, 10)
//       save_run_screen.dart    ← Form simpan sesi (Session 5, 7, 12)
//     widgets/
//       run_info_card.dart      ← Kartu info reusable (Session 4, 5)
//       history_tile.dart       ← Item riwayat (Session 4, 5)
//     utils/
//       constants.dart          ← Warna & gaya teks (Session 4)
//
// Materi yang diimplementasikan:
//   [Session 3]  Flutter sebagai platform cross-platform
//   [Session 4]  Pengenalan Flutter: widget, State, MaterialApp
//   [Session 5]  Layout, navigasi, Form, validasi
//   [Session 6]  State management: ChangeNotifier & Provider
//   [Session 7]  Data model, JSON serialization
//   [Session 10] Device feature: GPS / Geolocator
//   [Session 12] Local storage: Hive database
// ============================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/run_session.dart';
import 'providers/run_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

// [Session 4] Entry point — setiap program Dart dimulai dari main()
// async karena kita perlu menunggu inisialisasi Hive selesai
Future<void> main() async {
  // [Session 4] Memastikan Flutter binding diinisialisasi sebelum
  // memanggil kode platform (seperti Hive yang butuh path dari sistem)
  WidgetsFlutterBinding.ensureInitialized();

  // [Session 12] Inisialisasi Hive dengan path yang sesuai platform Android
  await Hive.initFlutter();

  // [Session 12] Daftarkan TypeAdapter yang di-generate oleh build_runner
  // Ini diperlukan agar Hive tahu cara serialize/deserialize RunSession
  Hive.registerAdapter(RunSessionAdapter());

  // [Session 12] Buka "box" (semacam tabel dalam database)
  // Data akan tetap tersimpan meski aplikasi ditutup
  await Hive.openBox<RunSession>('run_sessions');

  // Jalankan aplikasi
  runApp(const RunnerMapApp());
}

// [Session 4] Root widget — StatelessWidget karena tidak punya state sendiri
// [Session 6] MultiProvider di sini agar Provider tersedia di seluruh widget tree
class RunnerMapApp extends StatelessWidget {
  const RunnerMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [Session 6] MultiProvider — menyediakan beberapa provider sekaligus
    // ChangeNotifierProvider membuat RunProvider tersedia ke seluruh app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RunProvider()),
      ],
      child: MaterialApp(
        title: 'Runner Map',
        debugShowCheckedModeBanner: false,

        // [Session 4] ThemeData — konfigurasi tema global
        theme: ThemeData(
          // Gunakan warna orange sebagai seed
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.orange,
            brightness: Brightness.light,
          ),
          // Warna scaffold background sesuai tema beige dari mockup
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Roboto',

          // Kustomisasi AppBar agar sesuai tema
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
        ),

        // [Session 5] Home screen sebagai halaman awal
        home: const HomeScreen(),
      ),
    );
  }
}
