import 'package:latlong2/latlong.dart';

/// Represents a destination point in the route plan
class Destination {
  final String id;
  final String name;
  final LatLng latlng;

  Destination({required this.id, required this.name, required this.latlng});

  /// Convert from Map (for backward compatibility)
  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] as String,
      name: map['name'] as String,
      latlng: map['latlng'] as LatLng,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'latlng': latlng};
  }

  Destination copyWith({String? id, String? name, LatLng? latlng}) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      latlng: latlng ?? this.latlng,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Destination && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
