import 'package:latlong2/latlong.dart';

/// Represents a single leg/segment of a route between two points
class RouteLeg {
  final LatLng from;
  final LatLng to;
  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;

  RouteLeg({
    required this.from,
    required this.to,
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });

  RouteLeg copyWith({
    LatLng? from,
    LatLng? to,
    List<LatLng>? points,
    double? distanceKm,
    double? durationMin,
  }) {
    return RouteLeg(
      from: from ?? this.from,
      to: to ?? this.to,
      points: points ?? this.points,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
    );
  }
}
