import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyPlan extends StatefulWidget {
  const MyPlan({super.key});

  @override
  State<MyPlan> createState() => _MyPlanState();
}

class _MyPlanState extends State<MyPlan> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng SourceLoc = LatLng(2.313975, 98.806991);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plan")),
      // body: GoogleMap(
      //   initialCameraPosition: CameraPosition(target: SourceLoc, zoom: 14.5),
      // ),
    );
  }
}
