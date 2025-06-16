import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySelectCategory extends StatelessWidget {
  final String categoryName;

  const MySelectCategory({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: Provider.of<MytripProvider>(
          context,
          listen: false,
        ).loadTripsFromFirestore().then((_) {
          Provider.of<MytripProvider>(
            context,
            listen: false,
          ).filterByCategory(categoryName);
        }),
        builder: (context, snapshot) {
          return Consumer<MytripProvider>(
            builder: (context, tripProvider, _) {
              final trips = tripProvider.categoryTrips;

              if (trips.isEmpty) {
                return Center(child: Text("Tidak ada trip di kategori ini."));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return TripCardGridItem(trip: trips[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
