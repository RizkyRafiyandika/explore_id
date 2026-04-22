import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';
import '../models/destination.dart';
import '../models/route_leg.dart';

/// Widget for a single destination item in the list
class DestinationListItem extends StatelessWidget {
  final int index;
  final Destination destination;
  final RouteLeg? leg;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const DestinationListItem({
    super.key,
    required this.index,
    required this.destination,
    this.leg,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isStartPoint = index == -1;

    late Widget content = Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                isStartPoint ? tdcyan.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isStartPoint ? Icons.radio_button_checked : Icons.location_on,
            color: isStartPoint ? tdcyan : Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          isStartPoint ? "My Location" : destination.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          isStartPoint
              ? "Starting Point"
              : leg == null
              ? "Destination • Calculating..."
              : "Destination • ${leg!.distanceKm.toStringAsFixed(1)} km away",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            isStartPoint
                ? null
                : const Icon(Icons.more_vert, color: Colors.grey),
        onTap: onTap,
      ),
    );

    if (isStartPoint) return content;

    return Dismissible(
      key: ValueKey(destination.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: content,
    );
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) return "${minutes.round()} min";
    final h = (minutes ~/ 60);
    final m = (minutes % 60).round();
    if (m == 0) return "$h h";
    return "$h h $m min";
  }
}
