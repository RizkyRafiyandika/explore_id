import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';

/// Widget displaying route summary (distance and duration)
class RouteSummaryCard extends StatelessWidget {
  final bool isBuildingRoute;
  final double distanceKm;
  final double durationMin;
  final VoidCallback onFitRoutePressed;

  const RouteSummaryCard({
    super.key,
    required this.isBuildingRoute,
    required this.distanceKm,
    required this.durationMin,
    required this.onFitRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasStats = distanceKm > 0 && durationMin > 0;

    if (!hasStats && !isBuildingRoute) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FASTEST ROUTE",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBuildingRoute
                          ? "Calculating..."
                          : "Total: ${distanceKm.toStringAsFixed(1)} km • ${_formatDuration(durationMin)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: tdcyan,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onFitRoutePressed,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tdcyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.zoom_out_map, color: tdcyan, size: 24),
                ),
              ),
            ],
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
