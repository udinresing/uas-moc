// ============================================================
// history_tile.dart — Runner Map
//
// Widget yang menampilkan satu item riwayat lari di HomeScreen.
//
// [Session 4] StatelessWidget — widget reusable yang sederhana
// [Session 5] ListTile pattern untuk layout data yang konsisten
// [Session 7] Menerima RunSession object (model data) sebagai input
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/run_session.dart';
import '../utils/constants.dart';

class HistoryTile extends StatelessWidget {
  final RunSession session;
  final VoidCallback? onTap;

  const HistoryTile({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // [Session 7] Format tanggal menggunakan package intl
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(session.date);
    final timeStr = DateFormat('HH:mm').format(session.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,

        // Ikon berlari di kiri
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_run_rounded,
              color: AppColors.orange, size: 28),
        ),

        // Judul dan tanggal
        title: Text(
          session.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          '$dateStr · $timeStr',
          style: AppTextStyles.label.copyWith(fontSize: 12),
        ),

        // Stats di kanan
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Jarak
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: session.distanceKm.toStringAsFixed(2),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  const TextSpan(
                    text: ' km',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            // Durasi
            Text(
              session.formattedDuration,
              style: AppTextStyles.label.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
