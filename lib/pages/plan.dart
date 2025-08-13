import 'dart:async';

import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class MyPlan extends StatefulWidget {
  const MyPlan({Key? key}) : super(key: key);

  @override
  State<MyPlan> createState() => _MyPlanState();
}

class _MyPlanState extends State<MyPlan> with TickerProviderStateMixin {
  LatLng? currentLocation;
  final Location location = Location();
  final MapController _mapController = MapController();
  LatLng? destination;
  List<LatLng> route = [];
  final TextEditingController _destinationController = TextEditingController();
  bool isLoading = false;
  bool isSearching = false;

  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animations first
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Then initialize other components
    getCurrentLocation();
    _inisialiseLocation();

    if (globalTripEvent != null && globalDestination != null) {
      _destinationController.text = globalTripEvent!['place'];
      fetchRoute();
    }

    // Start animation after everything is initialized
    _animationController.forward();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _locationSubscription?.cancel();
    _animationController.dispose();
    globalTripEvent = null;
    globalDestination = null;
    super.dispose();
  }

  Future<void> _inisialiseLocation() async {
    if (!await _checkRequestPermission()) return;
    _locationSubscription = location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        if (!mounted) return;
        setState(() {
          currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        });
      }
    });
  }

  Future<bool> _checkRequestPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoading = true);
    final loc = await location.getLocation();
    if (!mounted) return;
    final newLocation = LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0);
    setState(() {
      currentLocation = newLocation;
      isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(newLocation, _mapController.camera.zoom);
    });
  }

  Future<void> fetchCoordinatePoint(String string) async {
    setState(() => isSearching = true);

    try {
      // Add more specific search parameters and user agent
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(string)}&format=json&addressdetails=1&limit=5&countrycodes=id",
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ExploreID/1.0 (your-email@example.com)'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final displayName = data[0]['display_name'] ?? string;

          setState(() {
            destination = LatLng(lat, lon);
            route.clear();
          });

          // Move map to destination first
          _mapController.move(destination!, 15);

          // Show success message
          customToast("Found: $displayName");

          // Then fetch route
          await fetchRoute();
        } else {
          customToast(
            "No location found for '$string'. Try being more specific.",
          );
        }
      } else {
        customToast("Search failed. Please try again.");
      }
    } catch (e) {
      customToast("Error occurred while searching: ${e.toString()}");
    }

    setState(() => isSearching = false);
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null || destination == null) {
      customToast("Current location or destination is not available.");
      return;
    }

    try {
      // Use HTTPS instead of HTTP for better reliability
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${currentLocation!.longitude},${currentLocation!.latitude};'
        '${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline&steps=true',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ExploreID/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final distance = data['routes'][0]['distance']; // in meters
          final duration = data['routes'][0]['duration']; // in seconds

          decodePolyline(geometry);

          // Show route info
          final distanceKm = (distance / 1000).toStringAsFixed(1);
          final durationMin = (duration / 60).round();
          customToast("Route found: ${distanceKm}km, ${durationMin} minutes");

          // Fit map to show both locations
          _fitMapToRoute();
        } else {
          customToast("No route found between these locations.");
        }
      } else {
        customToast("Failed to get route. Please try again.");
      }
    } catch (e) {
      customToast("Error getting route: ${e.toString()}");
    }
  }

  void _fitMapToRoute() {
    if (currentLocation != null && destination != null) {
      // Calculate bounds to fit both current location and destination
      final bounds = LatLngBounds(currentLocation!, destination!);

      // Add some padding
      final sw = LatLng(bounds.south - 0.01, bounds.west - 0.01);
      final ne = LatLng(bounds.north + 0.01, bounds.east + 0.01);
      final paddedBounds = LatLngBounds(sw, ne);

      _mapController.fitCamera(CameraFit.bounds(bounds: paddedBounds));
    }
  }

  void decodePolyline(String polyline) {
    PolylinePoints points = PolylinePoints();
    List<PointLatLng> decodedPoints = points.decodePolyline(polyline);
    setState(() {
      route =
          decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          currentLocation == null
              ? _buildLoadingScreen()
              : _fadeAnimation != null && _slideAnimation != null
              ? FadeTransition(
                opacity: _fadeAnimation!,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Column(
                    children: [_buildMapSection(), _buildContentSection()],
                  ),
                ),
              )
              : Column(children: [_buildMapSection(), _buildContentSection()]),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tdcyan.withOpacity(0.1), Colors.white],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(tdcyan),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Getting your location...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        child: Stack(
          children: [
            _MapPlan(
              mapController: _mapController,
              currentLocation: currentLocation,
              destination: destination,
              route: route,
            ),
            _buildSearchBar(),
            _buildCurrentLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _destinationController,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      fetchCoordinatePoint(value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: tdcyan,
                      size: 24,
                    ),
                    hintText: "Where do you want to go?",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tdcyan, tdcyan.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: tdcyan.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    isSearching
                        ? null
                        : () {
                          final query = _destinationController.text.trim();
                          if (query.isNotEmpty) {
                            fetchCoordinatePoint(query);
                          } else {
                            customToast("Destination cannot be empty");
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(60, 60),
                ),
                child:
                    isSearching
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tdcyan, tdcyan.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: tdcyan.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: isLoading ? null : getCurrentLocation,
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 24,
                  ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: globalTripEvent == null ? _buildNoTripCard() : _buildTripCard(),
      ),
    );
  }

  Widget _buildNoTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Trip Planned",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Plan your next adventure and it will appear here",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tdcyan.withOpacity(0.1), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tdcyan,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Trip Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailTile(
                    Icons.description,
                    "Description",
                    globalTripEvent!['title'],
                    globalTripEvent!['desk'],
                  ),
                  _buildDetailTile(
                    Icons.calendar_today,
                    "Date",
                    globalTripEvent!['date'].toString(),
                    null,
                  ),
                  _buildDetailTile(
                    Icons.access_time,
                    "Time",
                    "${globalTripEvent!['start']} - ${globalTripEvent!['end']}",
                    null,
                  ),
                  _buildDetailTile(
                    Icons.place,
                    "Location",
                    globalTripEvent!['place'],
                    "ID: ${globalTripEvent!['id']}",
                  ),
                  _buildDetailTile(
                    Icons.label,
                    "Category",
                    globalTripEvent!['label'],
                    null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    IconData icon,
    String title,
    String value,
    String? subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tdcyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tdcyan, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlan extends StatelessWidget {
  const _MapPlan({
    required MapController mapController,
    required this.currentLocation,
    required this.destination,
    required this.route,
  }) : _mapController = mapController;

  final MapController _mapController;
  final LatLng? currentLocation;
  final LatLng? destination;
  final List<LatLng> route;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: currentLocation!,
        initialZoom: 15,
        minZoom: 0,
        maxZoom: 18,
      ),
      children: [
        // SOLUSI 1: Gunakan CartoDB tiles (paling stabil)
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          additionalOptions: const {
            'attribution': '© OpenStreetMap contributors, © CartoDB',
          },
        ),

        // SOLUSI 2: Alternatif jika CartoDB tidak bekerja
        // TileLayer(
        //   urlTemplate: 'https://tiles.wmflabs.org/hikebike/{z}/{x}/{y}.png',
        //   additionalOptions: const {
        //     'attribution': '© OpenStreetMap contributors',
        //   },
        // ),

        // SOLUSI 3: Alternatif lain (Stamen)
        // TileLayer(
        //   urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.png',
        //   subdomains: const ['a', 'b', 'c', 'd'],
        //   additionalOptions: const {
        //     'attribution': 'Map tiles by Stamen Design, CC BY 3.0 — Map data © OpenStreetMap contributors',
        //   },
        // ),

        // SOLUSI 4: Jika ingin tetap menggunakan OSM, tambahkan retry mechanism
        // TileLayer(
        //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        //   additionalOptions: const {
        //     'attribution': '© OpenStreetMap contributors',
        //   },
        //   tileProvider: NetworkTileProvider(
        //     headers: {
        //       'User-Agent': 'ExploreID/1.0 (Flutter Map App)',
        //     },
        //   ),
        // ),
        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: tdcyan,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: tdcyan.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 12,
              ),
            ),
            markerSize: const Size(24, 24),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        if (destination != null)
          MarkerLayer(
            markers: [
              Marker(
                point: destination!,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        if (route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                strokeWidth: 5.0,
                color: tdcyan,
                pattern: const StrokePattern.solid(),
              ),
            ],
          ),
      ],
    );
  }
}
