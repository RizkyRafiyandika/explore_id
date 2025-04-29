import 'dart:async';
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

  final LatLng destinationLoc = const LatLng(-7.614015, 110.223894);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Cek apakah service lokasi aktif
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Cek izin akses lokasi
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final loc = await location.getLocation();

    setState(() {
      currentLocation = loc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Map')),
      body:
          currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                height: 400,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
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
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destinationLoc,
                      infoWindow: const InfoWindow(title: 'Destination'),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled:
                      true, // ← ini untuk tampilkan titik biru user
                  myLocationButtonEnabled:
                      true, // ← tombol buat lompat ke lokasi user
                ),
              ),
    );
  }
}
