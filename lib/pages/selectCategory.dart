import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MySelectCategory extends StatelessWidget {
  final String categoryName;

  const MySelectCategory({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MytripProvider>(context, listen: false);
    final Future<void> initFuture =
        provider.allTrip.isEmpty
            ? Future.wait([
              provider.loadTripsFromFirestore(),
              Future.delayed(const Duration(seconds: 1)),
            ]).then((_) => provider.filterByCategory(categoryName))
            : Future.delayed(
              const Duration(seconds: 1),
            ).then((_) => provider.filterByCategory(categoryName));
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<void>(
        future: initFuture,
        builder: (context, snapshot) {
          final bool isLoading =
              snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active;
          // Show a loading UI while fetching data
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            // Show a skeleton grid so user perceives layout and scrolling is smooth.
            return Column(
              children: [
                Expanded(
                  child: Skeletonizer(
                    enabled: isLoading,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Error loading data: ${snapshot.error}'),
                ],
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Consumer<MytripProvider>(
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
            ),
          );
        },
      ),
    );
  }
}
