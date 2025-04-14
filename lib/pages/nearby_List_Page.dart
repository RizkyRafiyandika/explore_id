import 'package:explore_id/models/listPlace.dart';
import 'package:explore_id/widget/filterButton.dart';
import 'package:flutter/material.dart';

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
            _restaurantList("Restaurant"),
            _restaurantList("Shop"),
            _restaurantList("Hotel"),
          ],
        ),
      ),
    );
  }

  Padding _restaurantList(String place) {
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
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (e) => MyDetailPlace(trip:trip)),
                    // );
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
                                  child: Image.asset(
                                    restaurant.imagePath,
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
                                      restaurant.name,
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
          Text(
            "Nearby",
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),

          SizedBox(
            height: 25,
            width: 25,
            child: Image.asset("assets/icons/heart.png"),
          ),
        ],
      ),
    );
  }
}
