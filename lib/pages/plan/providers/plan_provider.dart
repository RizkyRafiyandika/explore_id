import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination.dart';
import '../models/route_leg.dart';
import '../services/graphhopper_service.dart';
import '../services/location_service.dart';

/// Provider for managing plan/route state
/// Includes debouncing and request cancellation to prevent double API calls
class PlanProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  // ===== STATE =====
  LatLng? _currentLocation;
  List<Destination> _destinations = [];
  List<LatLng> _routePolyline = [];
  List<RouteLeg> _legs = [];
  String _travelMode = 'driving'; // 'driving', 'cycling', 'walking'

  // Loading states
  bool _isLoadingLocation = false;
  bool _isSearching = false;
  bool _isBuildingRoute = false;

  // Request tracking to prevent double calls
  int _lastRouteRequestId = 0;
  bool _isDisposed = false;

  // Animation trigger - increment when new route is ready
  int _routeAnimationTrigger = 0;

  // ===== GETTERS =====
  LatLng? get currentLocation => _currentLocation;
  List<Destination> get destinations => List.unmodifiable(_destinations);
  List<LatLng> get routePolyline => List.unmodifiable(_routePolyline);
  List<RouteLeg> get legs => List.unmodifiable(_legs);
  String get travelMode => _travelMode;
  int get routeAnimationTrigger => _routeAnimationTrigger;

  bool get isLoadingLocation => _isLoadingLocation;
  bool get isSearching => _isSearching;
  bool get isBuildingRoute => _isBuildingRoute;

  double get totalDistanceKm =>
      _legs.fold(0.0, (sum, leg) => sum + leg.distanceKm);
  double get totalDurationMin =>
      _legs.fold(0.0, (sum, leg) => sum + leg.durationMin);

  bool get hasDestinations => _destinations.isNotEmpty;
  bool get hasRoute => _routePolyline.isNotEmpty;

  // ===== INITIALIZATION =====

  /// Initialize location services and start tracking
  Future<void> initialize() async {
    await getCurrentLocation();
    startLocationTracking();
  }

  /// Start tracking location updates
  void startLocationTracking() {
    _locationService.startLocationUpdates((location) {
      if (!_isDisposed) {
        _currentLocation = location;
        notifyListeners();
      }
    });
  }

  // ===== LOCATION METHODS =====

  /// Get current location once
  Future<void> getCurrentLocation() async {
    if (_isLoadingLocation) return; // Prevent double call

    _isLoadingLocation = true;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null && !_isDisposed) {
        _currentLocation = location;
      }
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      if (!_isDisposed) {
        _isLoadingLocation = false;
        notifyListeners();
      }
    }
  }

  // ===== DESTINATION METHODS =====

  /// Add a destination from global context (from other screens)
  Future<void> addDestinationFromGlobal(LatLng latlng, String name) async {
    final destination = Destination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      latlng: latlng,
    );

    _destinations.add(destination);
    notifyListeners();

    // Automatically build route for this destination
    if (_currentLocation != null) {
      await rebuildRouteInCurrentOrder();
      // Trigger animation when new destination is added from global
      _routeAnimationTrigger++;
      notifyListeners();
    }
  }

  /// Search and add destination by query
  Future<String?> searchAndAddDestination(String query) async {
    if (query.trim().isEmpty || _isSearching) return null;

    _isSearching = true;
    notifyListeners();

    try {
      final result = await GraphHopperService.searchLocation(query);

      if (result != null && !_isDisposed) {
        final destination = Destination(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result['name'],
          latlng: result['latlng'],
        );

        _destinations.add(destination);

        // Build route after adding destination (with debounce protection)
        await fetchOptimizedRoute();

        return destination.name;
      } else {
        return null;
      }
    } catch (e) {
      print('Error searching destination: $e');
      rethrow;
    } finally {
      if (!_isDisposed) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  /// Add destination from suggestion (called when user selects from dropdown)
  /// This replaces searchAndAddDestination for better UX
  Future<void> addDestinationFromSuggestion(
    String name,
    double latitude,
    double longitude,
  ) async {
    final destination = Destination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      latlng: LatLng(latitude, longitude),
    );

    _destinations.add(destination);
    notifyListeners();

    // Build route after adding destination
    if (_currentLocation != null) {
      await fetchOptimizedRoute();
    }
  }

  /// Remove destination at index
  Future<void> removeDestinationAt(int index) async {
    if (index >= 0 && index < _destinations.length) {
      _destinations.removeAt(index);
      notifyListeners();

      await rebuildRouteInCurrentOrder();
    }
  }

  /// Reorder destinations
  Future<void> reorderDestinations(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;

    final destination = _destinations.removeAt(oldIndex);
    _destinations.insert(newIndex, destination);

    notifyListeners();

    await rebuildRouteInCurrentOrder();
  }

  /// Clear all destinations and routes
  void clearAll() {
    _destinations.clear();
    _routePolyline.clear();
    _legs.clear();
    notifyListeners();
  }

  // ===== ROUTE METHODS =====

  /// Change travel mode and rebuild route
  Future<void> changeTravelMode(String mode) async {
    if (_travelMode == mode || _isBuildingRoute) return;

    final oldMode = _travelMode;
    _travelMode = mode;
    notifyListeners();

    print('🔄 Changing travel mode from $oldMode to $mode');

    await rebuildRouteInCurrentOrder();
  }

  /// Fetch optimized route using greedy nearest-neighbor algorithm
  Future<void> fetchOptimizedRoute() async {
    if (_currentLocation == null || _destinations.isEmpty || _isBuildingRoute) {
      return;
    }

    // Generate unique request ID to track this request
    final requestId = ++_lastRouteRequestId;

    _isBuildingRoute = true;
    _routePolyline.clear();
    _legs.clear();
    notifyListeners();

    try {
      // Greedy nearest-neighbor optimization
      final remaining = List<Destination>.from(_destinations);
      final ordered = <Destination>[];

      LatLng cursor = _currentLocation!;
      while (remaining.isNotEmpty) {
        // Check if this request was cancelled
        if (requestId != _lastRouteRequestId || _isDisposed) {
          print('⚠️ Route request $requestId cancelled');
          return;
        }

        // Sort by distance from cursor
        remaining.sort((a, b) {
          final d1 = _locationService.calculateDistance(cursor, a.latlng);
          final d2 = _locationService.calculateDistance(cursor, b.latlng);
          return d1.compareTo(d2);
        });

        final next = remaining.removeAt(0);
        ordered.add(next);
        cursor = next.latlng;
      }

      // Build route with optimized order
      List<LatLng> fullRoute = [];
      List<RouteLeg> builtLegs = [];

      LatLng lastPoint = _currentLocation!;
      for (var dest in ordered) {
        // Check if this request was cancelled
        if (requestId != _lastRouteRequestId || _isDisposed) {
          print('⚠️ Route request $requestId cancelled during build');
          return;
        }

        final segment = await GraphHopperService.fetchRouteSegment(
          lastPoint,
          dest.latlng,
          _travelMode,
        );
        builtLegs.add(segment);
        fullRoute.addAll(segment.points);
        lastPoint = dest.latlng;
      }

      // Final check before updating state
      if (requestId != _lastRouteRequestId || _isDisposed) {
        print('⚠️ Route request $requestId cancelled before state update');
        return;
      }

      // Update state
      _destinations = ordered;
      _routePolyline = fullRoute;
      _legs = builtLegs;
      _routeAnimationTrigger++; // Trigger animation

      print('✅ Route optimized: ${_destinations.length} destinations');
      print(
        '📊 Total - Distance: ${totalDistanceKm.toStringAsFixed(2)} km, '
        'Duration: ${totalDurationMin.toStringAsFixed(1)} min',
      );
    } catch (e) {
      print('Error building optimized route: $e');
    } finally {
      if (!_isDisposed && requestId == _lastRouteRequestId) {
        _isBuildingRoute = false;
        notifyListeners();
      }
    }
  }

  /// Rebuild route in current order (after reordering or mode change)
  Future<void> rebuildRouteInCurrentOrder() async {
    if (_currentLocation == null || _destinations.isEmpty) {
      _routePolyline.clear();
      _legs.clear();
      if (!_isDisposed) notifyListeners();
      return;
    }

    if (_isBuildingRoute) return; // Prevent double call

    // Generate unique request ID to track this request
    final requestId = ++_lastRouteRequestId;

    print(
      '\n🔄 Rebuilding route with mode: $_travelMode (request: $requestId)',
    );
    print('📍 Destinations count: ${_destinations.length}');

    _isBuildingRoute = true;
    _routePolyline.clear();
    _legs.clear();
    notifyListeners();

    try {
      List<LatLng> fullRoute = [];
      List<RouteLeg> builtLegs = [];

      LatLng lastPoint = _currentLocation!;
      for (var dest in _destinations) {
        // Check if this request was cancelled
        if (requestId != _lastRouteRequestId || _isDisposed) {
          print('⚠️ Rebuild request $requestId cancelled');
          return;
        }

        print('\n🎯 Fetching segment to: ${dest.name}');
        final segment = await GraphHopperService.fetchRouteSegment(
          lastPoint,
          dest.latlng,
          _travelMode,
        );
        builtLegs.add(segment);
        fullRoute.addAll(segment.points);
        lastPoint = dest.latlng;
      }

      // Final check before updating state
      if (requestId != _lastRouteRequestId || _isDisposed) {
        print('⚠️ Rebuild request $requestId cancelled before state update');
        return;
      }

      _routePolyline = fullRoute;
      _legs = builtLegs;

      print(
        '\n📊 Total - Distance: ${totalDistanceKm.toStringAsFixed(2)} km, '
        'Duration: ${totalDurationMin.toStringAsFixed(1)} min',
      );
      print('═══════════════════════════════════════\n');
    } catch (e) {
      print('Error rebuilding route: $e');
    } finally {
      if (!_isDisposed && requestId == _lastRouteRequestId) {
        _isBuildingRoute = false;
        notifyListeners();
      }
    }
  }

  // ===== CLEANUP =====

  @override
  void dispose() {
    _isDisposed = true;
    _locationService.dispose();
    super.dispose();
  }
}
