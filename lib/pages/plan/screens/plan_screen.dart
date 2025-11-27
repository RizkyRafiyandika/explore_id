import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/widget/customeToast.dart';

import '../providers/plan_provider.dart';
import '../providers/search_suggestion_notifier.dart';
import '../widgets/route_summary_card.dart';
import '../widgets/destination_list_item.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/mode_selector.dart';
import '../widgets/animated_polyline.dart';

/// Main screen for route planning feature
class PlanScreen extends StatefulWidget {
  const PlanScreen({Key? key}) : super(key: key);

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

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlanProvider>();
      provider.initialize();
      _checkGlobalDestination(provider);
    });

    _animationController.forward();
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
              child: Column(
                children: [
                  _buildMapSection(provider),
                  _buildToolbar(provider),
                  _buildContentSection(provider),
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
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final double mapHeight =
        keyboardOpen ? MediaQuery.of(context).size.height * 0.35 : 460.0;

    return SizedBox(
      height: mapHeight,
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
                const CurrentLocationLayer(),
                if (provider.hasDestinations)
                  MarkerLayer(
                    markers: [
                      // Numbered markers for destinations
                      ...provider.destinations.asMap().entries.map((e) {
                        final idx = e.key;
                        final dest = e.value;
                        return Marker(
                          point: dest.latlng,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
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
                      // Current location marker
                      if (provider.currentLocation != null)
                        Marker(
                          point: provider.currentLocation!,
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
                if (provider.hasRoute)
                  AnimatedPolylineLayer(
                    key: ValueKey(provider.routeAnimationTrigger),
                    points: provider.routePolyline,
                    color: tdcyan,
                    strokeWidth: 5.0,
                    duration: const Duration(milliseconds: 1500),
                  ),
              ],
            ),
          ),

          // Unified Search Bar with Suggestions Dropdown
          UnifiedSearchBarWidget(
            controller: _destinationController,
            isSearching: provider.isSearching,
            suggestionNotifier: _searchSuggestionNotifier,
            onChanged: (value) {
              // Hanya update UI, jangan auto-submit
            },
            onSuggestionSelected: (suggestion) async {
              // Ketika user memilih dari dropdown
              await provider.addDestinationFromSuggestion(
                suggestion.name,
                suggestion.latitude,
                suggestion.longitude,
              );
              customToast("Destinasi ditambahkan: ${suggestion.name}");
            },
            onAddPressed: () async {
              // Manual submit via tombol add
              final query = _destinationController.text.trim();
              if (query.isNotEmpty) {
                await _handleManualSearch(provider, query);
              }
            },
          ),

          // Right-side floating action buttons
          Positioned(
            bottom: 18,
            right: 16,
            child: Column(
              children: [
                _smallFab(
                  tooltip: 'Fit to route',
                  icon: Icons.zoom_out_map,
                  onTap: () => _fitMapToAll(provider),
                ),
                const SizedBox(height: 10),
                _smallFab(
                  tooltip: 'Lokasi saya',
                  icon: Icons.my_location,
                  disabled: provider.isLoadingLocation,
                  onTap: () async {
                    await provider.getCurrentLocation();
                    if (provider.currentLocation != null) {
                      _mapController.move(
                        provider.currentLocation!,
                        _mapController.camera.zoom,
                      );
                    }
                  },
                  isLoading: provider.isLoadingLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleManualSearch(PlanProvider provider, String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    try {
      // Untuk manual search, gunakan first suggestion dari Nominatim
      final result = await provider.searchAndAddDestination(query);
      if (result != null) {
        customToast("Destinasi ditambahkan: $result");
        _destinationController.clear();
        _searchSuggestionNotifier.clearSuggestions();
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
      heroTag: tooltip ?? icon.codePoint,
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

  Widget _buildToolbar(PlanProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Travel mode selector
            ModeSelector(
              selectedMode: provider.travelMode,
              disabled: provider.isBuildingRoute,
              onModeChanged: (mode) async {
                final oldMode = provider.travelMode;
                customToast("Mengubah mode dari $oldMode ke $mode...");

                await provider.changeTravelMode(mode);

                if (provider.totalDistanceKm > 0) {
                  customToast(
                    "Mode $mode: ${provider.totalDistanceKm.toStringAsFixed(2)} km, "
                    "${provider.totalDurationMin.toStringAsFixed(0)} menit",
                  );
                } else {
                  customToast("Mode diubah ke $mode");
                }
              },
            ),
            const SizedBox(width: 16),
            // Actions
            _toolbarButton(
              icon: Icons.auto_awesome,
              label: 'Optimize',
              onTap:
                  !provider.hasDestinations || provider.isBuildingRoute
                      ? null
                      : () async {
                        await provider.fetchOptimizedRoute();
                        _fitMapToAll(provider);
                        customToast(
                          "Rute dioptimasi: ${provider.destinations.length} tujuan siap!",
                        );
                      },
            ),
            const SizedBox(width: 8),
            _toolbarButton(
              icon: Icons.cleaning_services,
              label: 'Clear',
              onTap:
                  !provider.hasDestinations && !provider.hasRoute
                      ? null
                      : () {
                        provider.clearAll();
                        customToast("Semua destinasi dihapus");
                      },
            ),
          ],
        ),
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
      icon:
          disabled
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

  Widget _buildContentSection(PlanProvider provider) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            RouteSummaryCard(
              isBuildingRoute: provider.isBuildingRoute,
              distanceKm: provider.totalDistanceKm,
              durationMin: provider.totalDurationMin,
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildDestinationList(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationList(PlanProvider provider) {
    if (!provider.hasDestinations) {
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

    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + keyboardBottom),
      itemCount: provider.destinations.length,
      onReorder: (oldIndex, newIndex) async {
        await provider.reorderDestinations(oldIndex, newIndex);
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
        final dest = provider.destinations[index];
        final leg = index < provider.legs.length ? provider.legs[index] : null;

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
