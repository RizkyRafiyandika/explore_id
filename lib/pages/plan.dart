import 'dart:async';

import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart'; // <- Pastikan ini digunakan, bukan yang dari Google Maps
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Tambahkan ini di bagian import

class MyPlan extends StatefulWidget {
  const MyPlan({Key? key}) : super(key: key);

  @override
  State<MyPlan> createState() => _MyPlanState();
}

class _MyPlanState extends State<MyPlan> {
  LatLng? currentLocation;
  final Location location = Location();
  final MapController _mapController = MapController();
  LatLng? destination;
  List<LatLng> route = [];
  final TextEditingController _destinationController = TextEditingController();

  StreamSubscription<LocationData>? _locationSubscription;

  Future<void> _inisialiseLocation() async {
    if (!await _checkRequestPermission()) return;
    _locationSubscription = location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        if (!mounted) return; // Check if the widget is still mounted
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
    final loc = await location.getLocation();
    if (!mounted) return;
    final newLocation = LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0);
    setState(() {
      currentLocation = newLocation;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(newLocation, _mapController.camera.zoom);
    });
  }

  Future<void> fetchCoordinatePoint(String string) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$string&format=json&addressdetails=1&limit=1",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          destination = LatLng(lat, lon);
          route.clear();
        });
        await fetchRoute();
      } else {
        customToast("No data found for the given string.");
      }
    } else {
      customToast("Failed to fetch coordinates: ${response.statusCode}");
    }
  }

  Future<void> fetchRoute() async {
    if (currentLocation != null && destination != null) {
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${currentLocation!.longitude},${currentLocation!.latitude};'
        '${destination!.longitude},${destination!.latitude}?overview=full&geometries=polyline',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final geometry = data['routes'][0]['geometry'];
        decodePolyline(geometry);
      }
    } else {
      customToast("Current location or destination is not set.");
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
  void initState() {
    super.initState();
    getCurrentLocation();
    _inisialiseLocation();

    if (globalTripEvent != null && globalDestination != null) {
      _destinationController.text = globalTripEvent!['place'];
      fetchRoute();
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _locationSubscription?.cancel();
    globalTripEvent = null;
    globalDestination = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Stack(
                    children: [
                      _MapPlan(
                        mapController: _mapController,
                        currentLocation: currentLocation,
                        destination: destination,
                        route: route,
                      ),
                      _currentButton(),
                      _SearchPlan(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(child: _descriptionEvent()),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
    );
  }

  Positioned _SearchPlan() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: tdwhitepure,
                    prefixIcon: Icon(Icons.location_on_sharp),
                    hintText: "Enter destination...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final query = _destinationController.text.trim();
                if (query.isNotEmpty) {
                  fetchCoordinatePoint(query);
                } else {
                  customToast("Destination cannot be empty");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tdcyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Icon(Icons.search, color: tdwhitepure),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _currentButton() {
    return Positioned(
      bottom: 12,
      right: 12,
      child: FloatingActionButton(
        backgroundColor: tdcyan,
        elevation: 3,
        onPressed: getCurrentLocation,
        child: const Icon(Icons.my_location, color: tdwhitepure),
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
    return SizedBox(
      height: 400,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentLocation!,
          initialZoom: 15,
          minZoom: 0,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          CurrentLocationLayer(
            style: LocationMarkerStyle(
              marker: Image.asset("assets/icons/mark_current.png"),
              markerSize: Size(20, 20),
              markerDirection: MarkerDirection.heading,
            ),
          ),
          if (destination != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: destination!,
                  child: Image.asset(
                    "assets/icons/mark_destination.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          if (route.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(points: route, strokeWidth: 4.0, color: tdwhiteblue),
              ],
            ),
        ],
      ),
    );
  }
}

class _descriptionEvent extends StatelessWidget {
  const _descriptionEvent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:
          globalTripEvent == null
              ? Container(
                height: MediaQuery.of(context).size.height * 0.5,
                alignment: Alignment.center,
                child: Text(
                  "No plan for today",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
              : Card(
                elevation: 5,
                color: tdwhitepure,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Trip Description",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.description),
                        title: Text(globalTripEvent!['title']),
                        subtitle: Text(globalTripEvent!['desk']),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text("Date"),
                        subtitle: Text(globalTripEvent!['date'].toString()),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time),
                        title: const Text("Start - End"),
                        subtitle: Text(
                          "${globalTripEvent!['start']} - ${globalTripEvent!['end']}",
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.place),
                        title: const Text("Place"),
                        subtitle: Text(
                          "${globalTripEvent!['place']} - ${globalTripEvent!['id']}",
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.label),
                        title: const Text("Label"),
                        subtitle: Text(globalTripEvent!['label']),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
