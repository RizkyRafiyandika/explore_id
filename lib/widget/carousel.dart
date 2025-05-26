import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ListExplore extends StatefulWidget {
  @override
  _ListExploreState createState() => _ListExploreState();
}

class _ListExploreState extends State<ListExplore> {
  int _current = 0; // buat track posisi carousel
  late List<ListTrip> selectedTrips;

  @override
  void initState() {
    super.initState();
    selectedTrips = List.from(ListTrips)..shuffle();
    selectedTrips = selectedTrips.take(4).toList(); // ambil 3 random
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              // enlargeCenterPage: true,
              viewportFraction: 0.85,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index; // update posisi halaman
                });
              },
            ),
            items:
                selectedTrips.map((trip) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(trip.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    trip.label,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    trip.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                    ),
                                    onPressed: () {
                                      User? user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user == null || user.isAnonymous) {
                                        return cutomeSneakBar(
                                          context,
                                          "Silakan login terlebih dahulu untuk mengakses fitur ini.'",
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    MyDetailPlace(trip: trip),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text('Explore Now'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children:
          //       selectedTrips.asMap().entries.map((entry) {
          //         return Container(
          //           width: 8.0,
          //           height: 8.0,
          //           margin: const EdgeInsets.symmetric(
          //             vertical: 8.0,
          //             horizontal: 4.0,
          //           ),
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color:
          //                 _current == entry.key
          //                     ? Colors.blueAccent
          //                     : Colors.grey,
          //           ),
          //         );
          //       }).toList(),
          // ),
        ],
      ),
    );
  }
}
