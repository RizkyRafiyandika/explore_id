import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/pages/likes.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/filterButton.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyNearbyPage extends StatefulWidget {
  const MyNearbyPage({super.key});

  @override
  State<MyNearbyPage> createState() => _MyNearbyPageState();
}

class _MyNearbyPageState extends State<MyNearbyPage> {
  String selectedFilter = "All";
  void updateFilter(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: MyfilterButton(onfilterSelection: updateFilter),
            ),
            _restaurantList("Mountain"),
            _restaurantList("Culture"),
            _restaurantList("Nature"),
            _restaurantList("Culinary"),
            _restaurantList("Beach"),
            _restaurantList("Monument"),
          ],
        ),
      ),
    );
  }

  SingleChildRenderObjectWidget _restaurantList(String place) {
    final tripProvider = Provider.of<MytripProvider>(context);
    final trips =
        tripProvider.allTrip; // Assuming 'trips' is the list in your provider

    final filteredTrips =
        trips
            .where((trip) => trip.label.toLowerCase() == place.toLowerCase())
            .toList();

    if (filteredTrips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "No places available.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              place,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredTrips.length,
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (e) => MyDetailPlace(trip: trip),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    clipBehavior:
                        Clip.antiAlias, // Memastikan border radius bekerja
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          // Tambahkan Expanded agar layout tetap fleksibel
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    trip.imagePath,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    color: Colors.black.withOpacity(0.5),
                                    child: Text(
                                      trip.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NavBar()),
              );
            },
            child: Icon(Icons.arrow_back),
          ),
          Text(
            "Nearby",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyLikesPage()),
              );
            },
            child: Stack(
              children: [
                Icon(
                  Icons.favorite_border,
                  weight: 30,
                  color: Colors.black.withOpacity(0.6),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
