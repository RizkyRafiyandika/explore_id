import 'dart:async';
import 'package:explore_id/components/global.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MyPlan extends StatefulWidget {
  const MyPlan({Key? key}) : super(key: key);

  @override
  State<MyPlan> createState() => _MyPlanState();
}

class _MyPlanState extends State<MyPlan> {
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? currentLocation;
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    final loc = await location.getLocation();
    setState(() {
      currentLocation = loc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(
                    height: 350,
                    width: double.infinity,
                    child: _Map(
                      currentLocation: currentLocation,
                      controller: _controller,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(child: _descriptionEvent()),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
    );
  }
}

class _Map extends StatelessWidget {
  const _Map({
    required this.currentLocation,
    required Completer<GoogleMapController> controller,
  }) : _controller = controller;

  final LocationData? currentLocation;
  final Completer<GoogleMapController> _controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              globalDestination ??
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 14.5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
          if (globalDestination != null)
            Marker(
              markerId: const MarkerId('destination'),
              position: globalDestination!,
              infoWindow: const InfoWindow(title: 'Destination'),
            ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
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
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              globalTripEvent == null
                  ? const Center(
                    child: Text(
                      "No plan for today",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text(
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
