import 'package:explore_id/models/listTrip.dart';

class DestinationModel {
  final String id;
  final String name;
  final String daerah;
  final String description;
  final double price;
  final String imagePath;
  final String label;
  final double latitude;
  final double longitude;
  final String userId; // Added userId

  DestinationModel({
    required this.id,
    required this.name,
    required this.daerah,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  // Convert to ListTrip for API
  ListTrip toListTrip() {
    return ListTrip(
      id: id,
      name: name,
      daerah: daerah,
      desk: description,
      harga: price,
      imagePath: imagePath,
      label: label,
      latitude: latitude,
      longitude: longitude,
      userId: userId,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'daerah': daerah,
      'desk': description,
      'harga': price,
      'imagePath': imagePath,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
    };
  }

  // Create from JSON
  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'] as String?;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is required for DestinationModel');
    }
    return DestinationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      daerah: json['daerah'] ?? '',
      description: json['desk'] ?? '',
      price: (json['harga'] ?? 0).toDouble(),
      imagePath: json['imagePath'] ?? '',
      label: json['label'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      userId: userId,
    );
  }

  // Create from ListTrip
  factory DestinationModel.fromListTrip(ListTrip trip) {
    return DestinationModel(
      id: trip.id,
      name: trip.name,
      daerah: trip.daerah,
      description: trip.desk,
      price: trip.harga,
      imagePath: trip.imagePath,
      label: trip.label,
      latitude: trip.latitude,
      longitude: trip.longitude,
      userId: trip.userId,
    );
  }

  // Copy with updates
  DestinationModel copyWith({
    String? id,
    String? name,
    String? daerah,
    String? description,
    double? price,
    String? imagePath,
    String? label,
    double? latitude,
    double? longitude,
    String? userId,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      daerah: daerah ?? this.daerah,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      label: label ?? this.label,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
    );
  }
}
