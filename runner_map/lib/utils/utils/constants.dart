// ============================================================
// constants.dart — Runner Map
//
// Menyimpan semua warna dan konstanta desain aplikasi.
// Warna diambil langsung dari desain UI yang diberikan (PNG mockup).
//
// [Session 4] Penggunaan konstanta sebagai best practice Dart:
//   - Menggunakan `const` untuk nilai yang tidak berubah
//   - Memusatkan definisi warna agar mudah diubah
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // Warna latar belakang hangat (beige)
  static const Color background = Color(0xFFFCF5F1);

  // Warna aksen utama (orange) — digunakan pada tombol & tracking line
  static const Color orange = Color(0xFFDC7633);
  static const Color orangeLight = Color(0xFFE8956A);
  static const Color orangeDark = Color(0xFFB8612A);

  // Warna teks
  static const Color textDark = Color(0xFF2E1B0E);
  static const Color textMuted = Color(0xFF7A6252);

  // Warna border kartu
  static const Color cardBorder = Color(0xFF8B7355);

  // Warna kartu / permukaan
  static const Color cardSurface = Color(0xFFFFF8F4);

  // Warna tracking line di peta
  static const Color trackLine = Color(0xFFDC7633);
}

class AppTextStyles {
  // Label kecil (contoh: "TOTAL DISTANCE", "AVG PACE")
  static const TextStyle label = TextStyle(
    fontSize: 11,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  // Nilai besar (contoh: "6.42")
  static const TextStyle valueLarge = TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.0,
  );

  // Satuan nilai besar (contoh: "KM")
  static const TextStyle valueUnit = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Nilai medium (contoh: "00:36:14", "5:38")
  static const TextStyle valueMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // Judul halaman (contoh: "Active Run")
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.orange,
  );
}
