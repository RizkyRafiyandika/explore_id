import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

/// Service for handling device location and permissions
class LocationService {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  /// Check and request location permissions
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  /// Get current location once
  Future<LatLng?> getCurrentLocation() async {
    try {
      if (!await checkAndRequestPermissions()) {
        return null;
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        return null;
      }

      return LatLng(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Start listening to location updates
  /// [onLocationChanged] - Callback when location changes
  void startLocationUpdates(Function(LatLng) onLocationChanged) {
    _locationSubscription?.cancel();

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        onLocationChanged(
          LatLng(locationData.latitude!, locationData.longitude!),
        );
      }
    });
  }

  /// Stop listening to location updates
  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  /// Dispose resources
  void dispose() {
    stopLocationUpdates();
  }
}
