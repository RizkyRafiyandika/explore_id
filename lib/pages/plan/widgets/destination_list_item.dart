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
    Key? key,
    required this.index,
    required this.destination,
    this.leg,
    required this.onTap,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lat = destination.latlng.latitude.toStringAsFixed(5);
    final lng = destination.latlng.longitude.toStringAsFixed(5);

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
      child: Card(
        key: ValueKey('card_${destination.id}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: tdcyan.withOpacity(0.15),
            foregroundColor: tdcyan,
            child: Text(
              "${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            destination.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            leg == null
                ? "Lat: $lat, Lng: $lng"
                : "${leg!.distanceKm.toStringAsFixed(1)} km • ${_formatDuration(leg!.durationMin)}",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
          ),
          trailing: const Icon(Icons.drag_indicator, color: Colors.grey),
          onTap: onTap,
        ),
      ),
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
