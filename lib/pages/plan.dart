import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MyPlan extends StatefulWidget {
  const MyPlan({Key? key}) : super(key: key);

  @override
  State<MyPlan> createState() => _MyPlanState();
}

class _MyPlanState extends State<MyPlan> with TickerProviderStateMixin {
  LatLng? currentLocation;
  final Location location = Location();
  final MapController _mapController = MapController();

  // Destinations: { 'name': String, 'latlng': LatLng }
  List<Map<String, dynamic>> destinations = [];
  // Full route polyline
  List<LatLng> route = [];
  // Route legs (for per-segment stats)
  List<_RouteLeg> legs = [];

  final TextEditingController _destinationController = TextEditingController();
  bool isLoadingLocation = false;
  bool isSearching = false;
  bool isBuildingRoute = false;

  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  StreamSubscription<LocationData>? _locationSubscription;

  // New: travel mode
  String travelMode = 'driving'; // 'driving' | 'cycling' | 'walking'

  // Debounce untuk pencarian
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    getCurrentLocation();
    _inisialiseLocation();

    _animationController.forward();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _locationSubscription?.cancel();
    _animationController.dispose();
    _debounce?.cancel();
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
    setState(() => isLoadingLocation = true);
    try {
      final loc = await location.getLocation();
      if (!mounted) return;
      final newLocation = LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0);
      setState(() {
        currentLocation = newLocation;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      });
    } catch (e) {
      customToast("Gagal mendapatkan lokasi: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoadingLocation = false);
    }
  }

  // ---- Search & Add Destination ----

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) return;
    _debounce = Timer(_debounceDuration, () async {
      await fetchCoordinatePoint(query);
      _destinationController.clear();
    });
  }

  Future<void> fetchCoordinatePoint(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => isSearching = true);

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search"
        "?q=${Uri.encodeComponent(query)}"
        "&format=json&limit=1&countrycodes=id",
      );

      final response = await http.get(
        url,
        headers: {
          // Saran Nominatim: pakai user-agent + email/URL app
          'User-Agent': 'ExploreID/1.1.0 (+support@explore-id.app)',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());
          if (lat == null || lon == null) {
            customToast("Format koordinat tidak valid dari server.");
          } else {
            final displayName =
                (data[0]['display_name'] as String?)?.split(',').first.trim() ??
                query;

            setState(() {
              destinations.add({'name': displayName, 'latlng': LatLng(lat, lon)});
            });

            customToast("Destinasi ditambahkan: $displayName");

            // Build/refresh the route after adding a destination
            await fetchOptimizedRoute();
          }
        } else {
          customToast("Lokasi untuk '$query' tidak ditemukan.");
        }
      } else if (response.statusCode == 429) {
        customToast("Terlalu banyak permintaan. Coba lagi sebentar lagi.");
      } else {
        customToast("Pencarian gagal (code ${response.statusCode}).");
      }
    } catch (e) {
      customToast("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  // ---- Routing ----

  Future<void> fetchOptimizedRoute() async {
    if (currentLocation == null || destinations.isEmpty) {
      customToast("Lokasi atau destinasi belum tersedia.");
      return;
    }

    setState(() {
      isBuildingRoute = true;
      route.clear();
      legs.clear();
    });

    // Coba optimasi dengan OSRM Trip API dulu (jika >= 2 destinasi).
    bool usedTripApi = false;
    if (destinations.length >= 2) {
      try {
        final ok = await _fetchOptimizedRouteWithOsrmTrip();
        usedTripApi = ok;
      } catch (_) {
        usedTripApi = false;
      }
    }

    // Jika Trip API gagal/ditolak, fallback ke greedy nearest-neighbor
    if (!usedTripApi) {
      final remaining = List<Map<String, dynamic>>.from(destinations);
      final ordered = <Map<String, dynamic>>[];

      LatLng cursor = currentLocation!;
      while (remaining.isNotEmpty) {
        remaining.sort((a, b) {
          final d1 = _calculateDistance(cursor, a['latlng']);
          final d2 = _calculateDistance(cursor, b['latlng']);
          return d1.compareTo(d2);
        });
        final next = remaining.removeAt(0);
        ordered.add(next);
        cursor = next['latlng'];
      }

      List<LatLng> full = [];
      List<_RouteLeg> builtLegs = [];

      LatLng lastPoint = currentLocation!;
      for (var dest in ordered) {
        final segment = await _fetchRouteSegment(lastPoint, dest['latlng']);
        builtLegs.add(segment);
        full.addAll(segment.points);
        lastPoint = dest['latlng'];
      }

      if (!mounted) return;

      setState(() {
        destinations = ordered; // apply optimized order to UI
        route = full;
        legs = builtLegs;
        isBuildingRoute = false;
      });
    }

    _fitMapToAll();

    final msg = usedTripApi
        ? "Rute dioptimasi (Trip API): ${destinations.length} tujuan siap!"
        : "Rute dioptimasi (Greedy): ${destinations.length} tujuan siap!";
    customToast(msg);
  }

  Future<bool> _fetchOptimizedRouteWithOsrmTrip() async {
    // OSRM Trip API: optimalkan urutan titik (mirip TSP),
    // gunakan source=first agar mulai dari currentLocation.
    // roundtrip=false agar tidak kembali ke titik awal.
    try {
      final points = [
        currentLocation!,
        ...destinations.map<LatLng>((d) => d['latlng'] as LatLng),
      ];

      final coords = points
          .map((p) => "${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}")
          .join(';');

      final url = Uri.parse(
        'https://router.project-osrm.org/trip/v1/$travelMode/$coords'
        '?source=first&roundtrip=false&overview=full&geometries=polyline',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'ExploreID/1.1.0 (+support@explore-id.app)',
      });

      if (response.statusCode != 200) {
        // Gagal, biar fallback ke greedy
        return false;
      }

      final data = jsonDecode(response.body);
      if (data['trips'] == null || (data['trips'] as List).isEmpty) {
        return false;
      }

      final trip = data['trips'][0];
      final waypoints = (data['waypoints'] as List).cast<Map<String, dynamic>>();

      // Waypoints include 'waypoint_index' (order within request) and 'trips_index'
      // Order destinasi berdasarkan 'waypoint_index' hasil Trip API (skip index 0 karena currentLocation)
      // Catatan: waypoint 0 = currentLocation
      final orderedIndices = waypoints
          .where((w) => (w['waypoint_index'] as int) != 0)
          .toList()
        ..sort((a, b) =>
            (a['waypoint_index'] as int).compareTo(b['waypoint_index'] as int));

      final orderedDest = <Map<String, dynamic>>[];
      for (final w in orderedIndices) {
        final origIdx = (w['waypoint_index'] as int) - 1; // shift karena ada currentLocation di depan
        if (origIdx >= 0 && origIdx < destinations.length) {
          orderedDest.add(destinations[origIdx]);
        }
      }

      // Decode polyline full trip untuk tampilan keseluruhan
      final geometry = trip['geometry'];
      final tripDistance = (trip['distance'] as num?)?.toDouble() ?? 0;
      final tripDuration = (trip['duration'] as num?)?.toDouble() ?? 0;

      final pts = PolylinePoints()
          .decodePolyline(geometry)
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
      final simplifiedPts = _simplifyPolyline(pts);

      // Build legs detail (antar titik berurutan)
      final builtLegs = <_RouteLeg>[];
      LatLng lastPoint = currentLocation!;
      for (var dest in orderedDest) {
        final segment = await _fetchRouteSegment(lastPoint, dest['latlng']);
        builtLegs.add(segment);
        lastPoint = dest['latlng'];
      }

      if (!mounted) return true;

      setState(() {
        destinations = orderedDest;
        route = simplifiedPts;
        legs = builtLegs.isNotEmpty
            ? builtLegs
            : [
                _RouteLeg(
                  from: currentLocation!,
                  to: orderedDest.isNotEmpty ? orderedDest.last['latlng'] : currentLocation!,
                  points: simplifiedPts,
                  distanceKm: tripDistance / 1000.0,
                  durationMin: tripDuration / 60.0,
                ),
              ];
        isBuildingRoute = false;
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> rebuildRouteInCurrentOrder() async {
    if (currentLocation == null || destinations.isEmpty) {
      setState(() {
        route.clear();
        legs.clear();
      });
      return;
    }

    setState(() {
      isBuildingRoute = true;
      route.clear();
      legs.clear();
    });

    List<LatLng> full = [];
    List<_RouteLeg> builtLegs = [];

    LatLng lastPoint = currentLocation!;
    for (var dest in destinations) {
      final segment = await _fetchRouteSegment(lastPoint, dest['latlng']);
      builtLegs.add(segment);
      full.addAll(segment.points);
      lastPoint = dest['latlng'];
    }

    if (!mounted) return;

    setState(() {
      route = full;
      legs = builtLegs;
      isBuildingRoute = false;
    });

    _fitMapToAll();
  }

  Future<_RouteLeg> _fetchRouteSegment(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$travelMode/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}?overview=full&geometries=polyline',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ExploreID/1.1.0 (+support@explore-id.app)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route0 = data['routes'][0];
          final geometry = route0['geometry'];
          final distanceMeters = (route0['distance'] as num?)?.toDouble() ?? 0;
          final durationSeconds = (route0['duration'] as num?)?.toDouble() ?? 0;

          final pts = PolylinePoints()
              .decodePolyline(geometry)
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          final simplified = _simplifyPolyline(pts);

          return _RouteLeg(
            from: start,
            to: end,
            points: simplified,
            distanceKm: distanceMeters / 1000.0,
            durationMin: durationSeconds / 60.0,
          );
        } else {
          customToast("Tidak ada rute ditemukan.");
        }
      } else if (response.statusCode == 429) {
        customToast("Batas request OSRM tercapai (429). Coba lagi nanti.");
      } else {
        customToast("Gagal ambil rute (code: ${response.statusCode}).");
      }
    } catch (e) {
      customToast("Error saat ambil rute: $e");
    }

    return _RouteLeg(
      from: start,
      to: end,
      points: const [],
      distanceKm: 0,
      durationMin: 0,
    );
  }

  // ---- Helpers ----

  List<LatLng> _simplifyPolyline(List<LatLng> pts) {
    if (pts.length <= 2) return pts;
    // Cara cepat & aman: sampling tiap N titik + titik terakhir.
    // Bisa diganti Douglas-Peucker bila mau lebih presisi.
    final step = pts.length > 600 ? 8 : (pts.length > 300 ? 5 : 3);
    final simplifiedPts = <LatLng>[];
    for (int i = 0; i < pts.length; i += step) {
      simplifiedPts.add(pts[i]);
    }
    if (simplifiedPts.last != pts.last) simplifiedPts.add(pts.last);
    return simplifiedPts;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  void _fitMapToAll() {
    if (currentLocation == null && route.isEmpty && destinations.isEmpty) return;

    LatLngBounds? bounds;

    if (route.isNotEmpty) {
      bounds = LatLngBounds(route.first, route.first);
      for (var p in route) {
        bounds.extend(p);
      }
    } else if (destinations.isNotEmpty) {
      bounds = LatLngBounds(
        destinations.first['latlng'],
        destinations.first['latlng'],
      );
      for (var d in destinations) {
        bounds.extend(d['latlng']);
      }
      if (currentLocation != null) bounds.extend(currentLocation!);
    } else if (currentLocation != null) {
      bounds = LatLngBounds(currentLocation!, currentLocation!);
    }

    if (bounds != null) {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    }
  }

  void _removeDestinationAt(int index) {
    setState(() {
      destinations.removeAt(index);
    });
    rebuildRouteInCurrentOrder();
  }

  void _clearAll() {
    setState(() {
      destinations.clear();
      route.clear();
      legs.clear();
    });
  }

  double get totalDistanceKm => legs.fold(0.0, (sum, l) => sum + l.distanceKm);

  double get totalDurationMin => legs.fold(0.0, (sum, l) => sum + l.durationMin);

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: currentLocation == null
          ? _buildLoadingScreen()
          : FadeTransition(
              opacity: _fadeAnimation!,
              child: SlideTransition(
                position: _slideAnimation!,
                child: Column(
                  children: [
                    _buildMapSection(),
                    _buildToolbar(),
                    _buildContentSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(child: CircularProgressIndicator(color: tdcyan));
  }

  Widget _buildMapSection() {
    return SizedBox(
      height: 460,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLocation!,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.exploreid.app',
                ),
                const CurrentLocationLayer(),
                if (destinations.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      // Numbered markers for destinations
                      ...destinations.asMap().entries.map((e) {
                        final idx = e.key;
                        final d = e.value;
                        return Marker(
                          point: d['latlng'],
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 36,
                              ),
                              Positioned(
                                top: 9,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${idx + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Marker for current location (start)
                      if (currentLocation != null)
                        Marker(
                          point: currentLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: tdcyan,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                if (route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: route, strokeWidth: 5.0, color: tdcyan),
                    ],
                  ),
              ],
            ),
          ),

          // Search Bar
          _buildSearchBar(),

          // Right-side floating action buttons
          Positioned(
            bottom: 18,
            right: 16,
            child: Column(
              children: [
                _smallFab(
                  tooltip: 'Fit to route',
                  icon: Icons.zoom_out_map,
                  onTap: _fitMapToAll,
                ),
                const SizedBox(height: 10),
                _smallFab(
                  tooltip: 'Lokasi saya',
                  icon: Icons.my_location,
                  disabled: isLoadingLocation,
                  onTap: getCurrentLocation,
                  isLoading: isLoadingLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallFab({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool disabled = false,
    bool isLoading = false,
  }) {
    return FloatingActionButton(
      heroTag: tooltip ?? icon.codePoint,
      onPressed: disabled ? null : onTap,
      backgroundColor: disabled ? Colors.grey : tdcyan,
      mini: true,
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, color: Colors.white),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.search, color: tdcyan),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _destinationController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: "Tambah destinasi (cth: Monas, Jakarta)",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    final q = value.trim();
                    if (q.isNotEmpty) {
                      fetchCoordinatePoint(q);
                      _destinationController.clear();
                      _debounce?.cancel();
                    }
                  },
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              if (isSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tdcyan,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.add_circle, color: tdcyan),
                  tooltip: 'Tambah destinasi',
                  onPressed: () {
                    final query = _destinationController.text.trim();
                    if (query.isNotEmpty) {
                      fetchCoordinatePoint(query);
                      _destinationController.clear();
                      _debounce?.cancel();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          // Travel mode chips
          Wrap(
            spacing: 8,
            children: [
              _modeChip('driving', Icons.directions_car),
              _modeChip('cycling', Icons.directions_bike),
              _modeChip('walking', Icons.directions_walk),
            ],
          ),
          const Spacer(),
          // Actions
          _toolbarButton(
            icon: Icons.auto_awesome,
            label: 'Optimize',
            onTap: destinations.isEmpty || isBuildingRoute
                ? null
                : fetchOptimizedRoute,
          ),
          const SizedBox(width: 8),
          _toolbarButton(
            icon: Icons.cleaning_services,
            label: 'Clear',
            onTap: destinations.isEmpty && route.isEmpty && legs.isEmpty
                ? null
                : _clearAll,
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String mode, IconData icon) {
    final selected = travelMode == mode;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(mode[0].toUpperCase() + mode.substring(1)),
        ],
      ),
      selected: selected,
      onSelected: (v) async {
        if (!v) return;
        setState(() => travelMode = mode);
        await rebuildRouteInCurrentOrder();
        customToast("Mode: $mode");
      },
      selectedColor: tdcyan.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? tdcyan : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: selected ? tdcyan : Colors.grey.shade300),
      ),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: disabled
          ? const SizedBox(width: 16, height: 16, child: SizedBox.shrink())
          : Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? Colors.grey.shade300 : tdcyan,
        foregroundColor: disabled ? Colors.grey.shade700 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: disabled ? 0 : 2,
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            RouteSummaryCard(
              isBuildingRoute: isBuildingRoute,
              distanceKm: totalDistanceKm,
              durationMin: totalDurationMin,
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildDestinationList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationList() {
    if (destinations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined, color: Colors.grey.shade400),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Belum ada destinasi. Tambahkan lewat kotak pencarian di atas ✨",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: destinations.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex -= 1;
        final item = destinations.removeAt(oldIndex);
        destinations.insert(newIndex, item);
        setState(() {});
        await rebuildRouteInCurrentOrder();
        customToast("Urutan diperbarui");
      },
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final d = destinations[index];
        final lat = d['latlng'].latitude.toStringAsFixed(5);
        final lng = d['latlng'].longitude.toStringAsFixed(5);

        // Segment stats if available (leg from prev point to this)
        _RouteLeg? leg;
        if (index < legs.length) {
          leg = legs[index];
        }

        return Dismissible(
          key: ValueKey('dest_$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeDestinationAt(index),
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
            key: ValueKey('card_$index'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                d['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                leg == null
                    ? "Lat: $lat, Lng: $lng"
                    : "${leg.distanceKm.toStringAsFixed(1)} km • ${_fmtMin(leg.durationMin)}",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
              ),
              trailing: const Icon(Icons.drag_indicator, color: Colors.grey),
              onTap: () {
                _mapController.move(d['latlng'], 16);
              },
            ),
          ),
        );
      },
    );
  }

  String _fmtMin(double minutes) {
    if (minutes < 60) return "${minutes.round()} min";
    final h = (minutes ~/ 60);
    final m = (minutes % 60).round();
    if (m == 0) return "$h h";
    return "$h h $m min";
  }
}

// ---- Small Data Class ----

class _RouteLeg {
  final LatLng from;
  final LatLng to;
  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;

  _RouteLeg({
    required this.from,
    required this.to,
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });
}

// ---- UI Widgets ----

class RouteSummaryCard extends StatelessWidget {
  final bool isBuildingRoute;
  final double distanceKm;
  final double durationMin;

  const RouteSummaryCard({
    Key? key,
    required this.isBuildingRoute,
    required this.distanceKm,
    required this.durationMin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasStats = distanceKm > 0 && durationMin > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: tdcyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasStats
                  ? "Total: ${distanceKm.toStringAsFixed(1)} km • ${_fmtMin(durationMin)}"
                  : "Belum ada rute. Tambah destinasi untuk melihat total.",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          if (isBuildingRoute)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: tdcyan),
            ),
        ],
      ),
    );
  }

  String _fmtMin(double minutes) {
    if (minutes < 60) return "${minutes.round()} min";
    final h = (minutes ~/ 60);
    final m = (minutes % 60).round();
    return m == 0 ? "$h h" : "$h h $m min";
  }
}
