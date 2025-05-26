import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:explore_id/widget/popUpAdd.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MyDetailPlace extends StatefulWidget {
  final ListTrip trip;

  const MyDetailPlace({super.key, required this.trip});

  @override
  State<MyDetailPlace> createState() => _MyDetailPlaceState();
}

class _MyDetailPlaceState extends State<MyDetailPlace> {
  bool _isExpanded = false;
  bool _isTextOverflow = false;
  final int maxLines = 5;
  List<ListTrip> AllTrip = ListTrips;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkTextOverflow();
  }

  void _checkTextOverflow() {
    final textSpan = TextSpan(
      text: widget.trip.desk,
      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
    );
    final tp = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width - 32);

    setState(() {
      _isTextOverflow = tp.didExceedMaxLines;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTotalLikes();
  }

  int _totalLikes = 0;

  void _loadTotalLikes() async {
    int totalLikes = await getTotalLikesForTrip(widget.trip.id);
    setState(() {
      _totalLikes = totalLikes;
    });
  }

  // Panggil fungsi ini saat tombol ditekan
  void showLocationDialog(
    BuildContext context,
    double latitude,
    double longitude,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(16),

            height: 500, // Total height for dialog
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title Text
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: tdwhiteblue, // Background color with opacity
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(
                        4,
                      ), // Padding inside the circle
                      child: Icon(Icons.location_on, color: tdwhite, size: 24),
                    ),
                    SizedBox(width: 5),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: tdwhiteblue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Map Container with fixed height for map
                ClipOval(
                  child: SizedBox(
                    height: 300, // Set map height here
                    width: 300, // Set map width here to make it a circle
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('locationMarker'),
                          position: LatLng(latitude, longitude),
                          infoWindow: InfoWindow(title: title),
                        ),
                      },
                      zoomControlsEnabled: false, // Disable zoom controls
                      zoomGesturesEnabled: false, // Disable zoom gestures
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Close Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tdcyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.exit_to_app_outlined, size: 18),
                      SizedBox(width: 4),
                      Text('Close'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double imageHeight = MediaQuery.of(context).size.height / 2.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image header with rounded bottom
            Stack(
              children: [
                _headerImage(widget: widget, imageHeight: imageHeight),

                // Back & Menu buttons
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(Icons.arrow_back, () {
                        Navigator.pop(context);
                      }),
                      _buildCircleButton(Icons.location_searching_outlined, () {
                        showLocationDialog(
                          context,
                          widget.trip.latitude, // <- dari data
                          widget.trip.longitude, // <- dari data
                          widget.trip.name, // <- nama tempat
                        );
                      }),
                    ],
                  ),
                ),
                Positioned(
                  top: 225,
                  right: 20,
                  child: Consumer<MytripProvider>(
                    builder: (context, tripProvider, _) {
                      final _isLiked = tripProvider.isTripLikedLocal(
                        widget.trip.id,
                      );
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color:
                                _isLiked
                                    ? Colors.red
                                    : Colors.black.withOpacity(0.5),
                          ),
                          onPressed: () async {
                            await tripProvider.toggleLike(widget.trip.id);

                            _loadTotalLikes();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Title + Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trip.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalLikes likes',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tdorange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.trip.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: tdcyan, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.trip.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.trip.desk,
                    textAlign: TextAlign.justify,
                    maxLines: _isExpanded ? null : maxLines,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isTextOverflow)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Show Less' : 'See All',
                        style: const TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Suggestion",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Builder(
                      builder: (context) {
                        final filteredTrips =
                            AllTrip.where(
                              (trip) =>
                                  trip.daerah == widget.trip.daerah &&
                                  trip.id != widget.trip.id,
                            ).toList();

                        if (filteredTrips.isEmpty) {
                          return const Center(
                            child: Text("No Suggestion for this Session"),
                          );
                        }

                        return GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 10,
                                childAspectRatio:
                                    2 /
                                    2, // Sesuaikan dengan tampilan TripCardGridItem
                              ),
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];
                            return TripCardGridItem(
                              trip: trip,
                              
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Add Button
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text("Add to Destination"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tdcyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        final trip = widget.trip;
                        showAddDestinationDialog(context, userId, trip);
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class _headerImage extends StatelessWidget {
  const _headerImage({required this.widget, required this.imageHeight});

  final MyDetailPlace widget;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Image.asset(
        widget.trip.imagePath,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
