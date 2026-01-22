import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../models/route_leg.dart';

/// Service for interacting with GraphHopper routing API
/// Can be easily switched between cloud API and localhost
class GraphHopperService {
  // ===== CONFIGURATION =====
  // Toggle between cloud API and localhost
  static const bool useLocalhost = false;

  // Localhost URL for self-hosted GraphHopper instance
  // Example usage: http://localhost:8989/route?point=lat,lng&point=lat,lng&vehicle=car
  static const String localhostUrl = 'http://localhost:8989';

  // Cloud API credentials
  static const String cloudApiKey = '0b293803-c0d8-432b-82b8-258603c0b632';
  static const String cloudBaseUrl = 'https://graphhopper.com/api/1';

  // ===== GETTERS =====
  static String get baseUrl => useLocalhost ? localhostUrl : cloudBaseUrl;

  static bool get isUsingLocalhost => useLocalhost;

  // ===== METHODS =====

  /// Fetch route segment between two points
  /// Returns a RouteLeg with polyline points, distance, and duration
  ///
  /// [start] - Starting point
  /// [end] - Ending point
  /// [travelMode] - Travel mode: 'driving', 'cycling', or 'walking'
  static Future<RouteLeg> fetchRouteSegment(
    LatLng start,
    LatLng end,
    String travelMode,
  ) async {
    try {
      // Convert travel mode to GraphHopper vehicle type
      final vehicle = _convertTravelModeToVehicle(travelMode);

      // Build URL based on configuration
      final Uri url;
      if (useLocalhost) {
        // Localhost format: /route?point=lat,lng&point=lat,lng&vehicle=car
        url = Uri.parse(
          '$localhostUrl/route?'
          'point=${start.latitude},${start.longitude}&'
          'point=${end.latitude},${end.longitude}&'
          'vehicle=$vehicle&'
          'locale=id&'
          'points_encoded=true',
        );
      } else {
        // Cloud API format with API key
        url = Uri.parse(
          '$cloudBaseUrl/route?'
          'point=${start.latitude},${start.longitude}&'
          'point=${end.latitude},${end.longitude}&'
          'vehicle=$vehicle&'
          'locale=id&'
          'points_encoded=true&'
          'key=$cloudApiKey',
        );
      }

      print('🚗 Fetching route with mode: $travelMode (vehicle: $vehicle)');
      print('📍 URL: ${_sanitizeUrlForLogging(url.toString())}');

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ExploreID/1.1.0 (+support@explore-id.app)'},
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['paths'] != null && data['paths'].isNotEmpty) {
          final path = data['paths'][0];
          final geometry = path['points'];
          final distanceMeters = (path['distance'] as num?)?.toDouble() ?? 0;
          final durationMillis = (path['time'] as num?)?.toDouble() ?? 0;

          print(
            '✅ Mode: $travelMode ($vehicle) | '
            'Distance: ${(distanceMeters / 1000).toStringAsFixed(2)} km | '
            'Duration: ${(durationMillis / 60000).toStringAsFixed(1)} min',
          );

          final points =
              PolylinePoints()
                  .decodePolyline(geometry)
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList();

          return RouteLeg(
            from: start,
            to: end,
            points: points,
            distanceKm: distanceMeters / 1000.0,
            durationMin: durationMillis / 60000.0,
          );
        } else {
          print('❌ No paths found in response');
          throw Exception('No paths found in response');
        }
      } else if (response.statusCode == 429) {
        print('⚠️ Rate limit exceeded');
        throw Exception('Rate limit exceeded (429). Please try again later.');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Failed to fetch route (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('💥 Error: $e');
      // Return empty leg on error
      return RouteLeg(
        from: start,
        to: end,
        points: const [],
        distanceKm: 0,
        durationMin: 0,
      );
    }
  }

  /// Search for location coordinates using GraphHopper Geocoding API
  /// Returns a map with 'name' and 'latlng' or null if not found
  ///
  /// [query] - Search query (e.g., "Monas, Jakarta")
  static Future<Map<String, dynamic>?> searchLocation(String query) async {
    if (query.trim().isEmpty) return null;

    try {
      final url = Uri.parse(
        '$cloudBaseUrl/geocode'
        '?q=${Uri.encodeComponent(query)}'
        '&locale=id'
        '&limit=1'
        '&key=$cloudApiKey',
      );

      print('🔍 Searching location: "$query"');
      print('📍 URL: ${_sanitizeUrlForLogging(url.toString())}');

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ExploreID/1.1.0 (+support@explore-id.app)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['hits'] != null && data['hits'].isNotEmpty) {
          final hit = data['hits'][0];
          final point = hit['point'];

          final name = hit['name'] ?? query;
          final latlng = LatLng(point['lat'], point['lng']);

          print('✅ Found: $name at (${point['lat']}, ${point['lng']})');

          return {'name': name, 'latlng': latlng};
        } else {
          print('❌ No results found for: "$query"');
        }
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else {
        throw Exception('Search failed (code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error searching location: $e');
      rethrow;
    }

    return null;
  }

  /// Search for multiple location suggestions using GraphHopper Geocoding API
  /// Returns a list of suggestions with full details
  ///
  /// [query] - Search query (e.g., "Monas, Jakarta")
  /// [limit] - Maximum number of suggestions to return (default: 5)
  static Future<List<Map<String, dynamic>>?> searchLocationSuggestions(
    String query, {
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return null;

    try {
      final url = Uri.parse(
        '$cloudBaseUrl/geocode'
        '?q=${Uri.encodeComponent(query)}'
        '&locale=id'
        '&limit=$limit'
        '&key=$cloudApiKey',
      );

      print('🔍 Searching suggestions for: "$query"');
      print('📍 URL: ${_sanitizeUrlForLogging(url.toString())}');

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ExploreID/1.1.0 (+support@explore-id.app)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['hits'] != null && data['hits'].isNotEmpty) {
          final suggestions = <Map<String, dynamic>>[];

          for (var hit in data['hits']) {
            try {
              final point = hit['point'];
              final lat = point['lat'] as double?;
              final lng = point['lng'] as double?;

              if (lat == null || lng == null) continue;

              suggestions.add({
                'id': hit['osm_id']?.toString() ?? '',
                'name': hit['name'] ?? query,
                'fullAddress': _formatAddress(hit),
                'latitude': lat,
                'longitude': lng,
              });
            } catch (e) {
              print('⚠️ Error parsing suggestion: $e');
              continue;
            }
          }

          print('✅ Found ${suggestions.length} suggestions');
          return suggestions.isNotEmpty ? suggestions : null;
        } else {
          print('❌ No suggestions found for: "$query"');
        }
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else {
        throw Exception('Search failed (code: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ Error searching suggestions: $e');
      rethrow;
    }

    return null;
  }

  // ===== HELPER METHODS =====

  /// Convert travel mode to GraphHopper vehicle type
  static String _convertTravelModeToVehicle(String travelMode) {
    switch (travelMode) {
      case 'driving':
        return 'car';
      case 'cycling':
        return 'bike';
      case 'walking':
        return 'foot';
      default:
        return 'car';
    }
  }

  /// Format address from GraphHopper geocoding response
  static String _formatAddress(Map<String, dynamic> hit) {
    final parts = <String>[];

    if (hit['name'] != null) parts.add(hit['name']);
    if (hit['city'] != null)
      parts.add(hit['city']);
    else if (hit['state'] != null)
      parts.add(hit['state']);
    else if (hit['country'] != null)
      parts.add(hit['country']);

    return parts.take(2).join(', ');
  }

  /// Sanitize URL for logging (hide API key)
  static String _sanitizeUrlForLogging(String url) {
    return url.replaceAll(cloudApiKey, '***API_KEY***');
  }
}
