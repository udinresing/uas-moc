// ============================================================
// run_info_card.dart — Runner Map
//
// Widget yang dapat digunakan ulang (reusable) untuk menampilkan
// satu unit informasi lari (label + nilai).
//
// [Session 4] StatelessWidget — widget yang tidak punya state sendiri
// [Session 5] Penggunaan BoxDecoration untuk desain kartu
//             sesuai dengan panduan UI/UX
// ============================================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';

// [Session 4] StatelessWidget: tidak memiliki state, cukup menerima
// data via constructor dan render ulang jika parentnya rebuild
class RunInfoCard extends StatelessWidget {
  final String label;    // Contoh: "TOTAL DISTANCE"
  final String value;    // Contoh: "6.42"
  final String? unit;    // Contoh: "KM" (opsional)
  final String? suffix;  // Contoh: "/km" (opsional, untuk pace)

  const RunInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // [Session 5] BoxDecoration untuk styling kartu dengan border
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label kecil di atas
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 6),

          // Row untuk nilai + unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nilai utama
              Text(value, style: AppTextStyles.valueMedium),

              // Unit (opsional) — contoh: "KM" atau "/km"
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit!, style: AppTextStyles.label),
                ),
              ],
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(suffix!,
                      style: AppTextStyles.label.copyWith(fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Variant khusus untuk kartu "TOTAL DISTANCE" yang lebih besar
class LargeDistanceCard extends StatelessWidget {
  final String distance; // Contoh: "6.42"

  const LargeDistanceCard({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL DISTANCE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(distance, style: AppTextStyles.valueLarge),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('KM', style: AppTextStyles.valueUnit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
