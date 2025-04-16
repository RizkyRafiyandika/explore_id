import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/widget/popUpAdd.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                ClipRRect(
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
                ),

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
                      _buildCircleButton(Icons.menu, () {
                        // TODO: menu action
                      }),
                    ],
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
                    child: Text(
                      widget.trip.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
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
