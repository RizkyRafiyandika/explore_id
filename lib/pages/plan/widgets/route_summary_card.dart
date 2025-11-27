import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';

/// Widget displaying route summary (distance and duration)
class RouteSummaryCard extends StatelessWidget {
  final bool isBuildingRoute;
  final double distanceKm;
  final double durationMin;

  const RouteSummaryCard({
    Key? key,
    required this.isBuildingRoute,
    required this.distanceKm,
    required this.durationMin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasStats = distanceKm > 0 && durationMin > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: tdcyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasStats
                  ? "Total: ${distanceKm.toStringAsFixed(1)} km • ${_formatDuration(durationMin)}"
                  : "Belum ada rute. Tambah destinasi untuk melihat total.",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          if (isBuildingRoute)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: tdcyan),
            ),
        ],
      ),
    );
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) return "${minutes.round()} min";
    final h = (minutes ~/ 60);
    final m = (minutes % 60).round();
    return m == 0 ? "$h h" : "$h h $m min";
  }
}
