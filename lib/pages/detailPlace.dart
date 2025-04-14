import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/widget/TcCustomeCurve.dart';
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
    tp.layout(
      maxWidth: MediaQuery.of(context).size.width - 32,
    ); // padding horizontal

    setState(() {
      _isTextOverflow = tp.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    double oneThirdScreenHeight = MediaQuery.of(context).size.height / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: Tccustomecurve(),
                  child: SizedBox(
                    height: oneThirdScreenHeight,
                    width: double.infinity,
                    child: Image.asset(
                      widget.trip.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Header Buttons
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: menu logic
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),

                // Location Text in image
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20, // Added right padding to prevent overflow
                  child: Flexible(
                    child: Text(
                      widget.trip.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Like Button
                Positioned(
                  bottom: 0,
                  right: 50,
                  child: Material(
                    elevation: 8,
                    shape: const CircleBorder(),
                    shadowColor: Colors.black.withOpacity(0.4),
                    color: Colors.white,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        // TODO: toggle like logic
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Detail content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Label
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, color: tdcyan, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    widget.trip.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tdorange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Label: ${widget.trip.label}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 20),

                  // Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tdcyan.withOpacity(0.8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        final trip = widget.trip;
                        showAddDestinationDialog(context, userId, trip);
                      },
                      child: const Text(
                        "Add to destination",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
