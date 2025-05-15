// my_plan.dart
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
      appBar: AppBar(title: const Text('My Plan')),
      body:
          currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                height: 400,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target:
                        globalDestination ??
                        LatLng(
                          currentLocation!.latitude!,
                          currentLocation!.longitude!,
                        ),
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
              ),
    );
  }
}
