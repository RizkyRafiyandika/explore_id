import 'package:explore_id/pages/plan/models/destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/widget/customeToast.dart';

import '../providers/plan_provider.dart';
import '../providers/search_suggestion_notifier.dart';
import '../services/plan_marker_factory.dart';
import '../widgets/route_summary_card.dart';
import '../widgets/destination_list_item.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/mode_selector.dart';
import '../widgets/animated_polyline.dart';

/// Main screen for route planning feature
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _destinationController = TextEditingController();
  late SearchSuggestionNotifier _searchSuggestionNotifier;

  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  final PlanMarkerFactory _markerFactory = PlanMarkerFactory.instance;

  @override
  void initState() {
    super.initState();

    _searchSuggestionNotifier = SearchSuggestionNotifier();

    // Initialize animations
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

    _initializeMarkerFactory();

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlanProvider>();
      provider.initialize();
      _checkGlobalDestination(provider);
    });

    _animationController.forward();
  }

  Future<void> _initializeMarkerFactory() async {
    await _markerFactory.ensureInitialized(markerSize: 160);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _animationController.dispose();
    _searchSuggestionNotifier.dispose();
    super.dispose();
  }

  /// Check if there's a global destination from another screen
  Future<void> _checkGlobalDestination(PlanProvider provider) async {
    if (globalDestination != null && globalTripEvent != null) {
      final lat = globalDestination!.latitude;
      final lng = globalDestination!.longitude;
      final name = globalTripEvent!['title'] ?? 'Selected Location';

      await provider.addDestinationFromGlobal(LatLng(lat, lng), name);

      // Clear globals
      globalDestination = null;
      globalTripEvent = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: false,
      body: Consumer<PlanProvider>(
        builder: (context, provider, child) {
          if (provider.currentLocation == null) {
            return _buildLoadingScreen();
          }

          return FadeTransition(
            opacity: _fadeAnimation!,
            child: SlideTransition(
              position: _slideAnimation!,
              child: Stack(
                children: [
                  // 1. Full Screen Map
                  _buildMapSection(provider),

                  // 2. Search Bar (Floating)
                  UnifiedSearchBarWidget(
                    controller: _destinationController,
                    isSearching: provider.isSearching,
                    suggestionNotifier: _searchSuggestionNotifier,
                    onChanged: (value) {},
                    onSuggestionSelected: (suggestion) async {
                      _destinationController.clear();
                      await provider.addDestinationFromSuggestion(
                        suggestion.name,
                        suggestion.latitude,
                        suggestion.longitude,
                      );
                      customToast("Destinasi ditambahkan: ${suggestion.name}");
                    },
                    onAddPressed: () async {
                      final query = _destinationController.text.trim();
                      if (query.isNotEmpty) {
                        _destinationController.clear();
                        await _handleManualSearch(provider, query);
                      }
                    },
                  ),

                  // 3. Travel Mode Selector (Below Search Bar)
                  Positioned(
                    top: 110,
                    left: 0,
                    right: 0,
                    child: ModeSelector(
                      selectedMode: provider.travelMode,
                      disabled: provider.isBuildingRoute,
                      onModeChanged: (mode) async {
                        await provider.changeTravelMode(mode);
                      },
                    ),
                  ),

                  // 4. Map Action Buttons (Right side)

                  // 5. Bottom Overlays
                  Positioned(
                    bottom:
                        20, // Add more bottom padding to clear global bottom nav
                    left: 0,
                    right: 0,
                    child: _buildBottomOverlays(provider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(child: CircularProgressIndicator(color: tdcyan));
  }

  Widget _buildMapSection(PlanProvider provider) {
    return Positioned.fill(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: provider.currentLocation!,
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
            retinaMode: true,
          ),
          if (provider.currentLocation != null || provider.hasDestinations)
            MarkerLayer(
              markers: [
                if (provider.currentLocation != null)
                  Marker(
                    point: provider.currentLocation!,
                    child: _markerFactory.buildCurrentMarker(),
                  ),
                ...provider.destinations.asMap().entries.map((e) {
                  final idx = e.key;
                  final dest = e.value;
                  return Marker(
                    point: dest.latlng,
                    width: 60,
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: _markerFactory.buildDestinationMarker(index: idx),
                  );
                }),
              ],
            ),
          if (provider.hasRoute)
            AnimatedPolylineLayer(
              key: ValueKey(provider.routeAnimationTrigger),
              points: provider.routePolyline,
              color: tdcyan,
              strokeWidth: 7.0, // Thicker line
              duration: const Duration(milliseconds: 1500),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlays(PlanProvider provider) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardOpen) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RouteSummaryCard(
            isBuildingRoute: provider.isBuildingRoute,
            distanceKm: provider.totalDistanceKm,
            durationMin: provider.totalDurationMin,
            onFitRoutePressed: () => _fitMapToAll(provider),
          ),
          const SizedBox(height: 8),
          if (provider.hasDestinations)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.25,
              ),
              child: _buildDestinationList(provider),
            ),
        ],
      ),
    );
  }

  Future<void> _handleManualSearch(PlanProvider provider, String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    try {
      final result = await provider.searchAndAddDestination(query);
      if (result != null) {
        customToast("Destinasi ditambahkan: $result");
      } else {
        customToast("Lokasi untuk '$query' tidak ditemukan.");
      }
    } catch (e) {
      customToast("Error: ${e.toString()}");
    }
  }

  Widget _smallFab({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool disabled = false,
    bool isLoading = false,
  }) {
    return FloatingActionButton(
      heroTag: tooltip ?? icon.codePoint.toString(),
      onPressed: disabled ? null : onTap,
      backgroundColor: disabled ? Colors.grey : tdcyan,
      mini: true,
      child:
          isLoading
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

  Widget _buildDestinationList(PlanProvider provider) {
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Static Starting Point (My Location)
          DestinationListItem(
            index: -1, // Special index for starting point
            destination: Destination(
              id: 'current_loc',
              name: "My Location",
              latlng: provider.currentLocation!,
            ),
            onTap: () {
              _mapController.move(provider.currentLocation!, 16);
            },
            onDismissed: () {},
          ),

          // 2. Reorderable Destinations
          ReorderableListView.builder(
            padding: EdgeInsets.fromLTRB(0, 0, 0, keyboardBottom),
            itemCount: provider.destinations.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) async {
              await provider.reorderDestinations(oldIndex, newIndex);
              customToast("Urutan diperbarui");
            },
            itemBuilder: (context, index) {
              final dest = provider.destinations[index];
              final leg =
                  index < provider.legs.length ? provider.legs[index] : null;

              return DestinationListItem(
                key: ValueKey(dest.id),
                index: index,
                destination: dest,
                leg: leg,
                onTap: () {
                  _mapController.move(dest.latlng, 16);
                },
                onDismissed: () async {
                  await provider.removeDestinationAt(index);
                  customToast("${dest.name} dihapus");
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _fitMapToAll(PlanProvider provider) {
    if (provider.currentLocation == null &&
        !provider.hasRoute &&
        !provider.hasDestinations) {
      return;
    }

    LatLngBounds? bounds;

    if (provider.hasRoute) {
      bounds = LatLngBounds(
        provider.routePolyline.first,
        provider.routePolyline.first,
      );
      for (var p in provider.routePolyline) {
        bounds.extend(p);
      }
    } else if (provider.hasDestinations) {
      bounds = LatLngBounds(
        provider.destinations.first.latlng,
        provider.destinations.first.latlng,
      );
      for (var dest in provider.destinations) {
        bounds.extend(dest.latlng);
      }
      if (provider.currentLocation != null) {
        bounds.extend(provider.currentLocation!);
      }
    } else if (provider.currentLocation != null) {
      bounds = LatLngBounds(
        provider.currentLocation!,
        provider.currentLocation!,
      );
    }

    if (bounds != null) {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    }
  }
}
