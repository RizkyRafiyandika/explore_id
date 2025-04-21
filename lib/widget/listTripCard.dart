import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:flutter/material.dart';
import 'package:explore_id/models/listTrip.dart';

class ListTripWidget extends StatelessWidget {
  final List<ListTrip> trips;

  const ListTripWidget({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          return TripCardGridItem(trip: trips[index]);
        },
      ),
    );
  }
}

class TripCardGridItem extends StatelessWidget {
  final ListTrip trip;

  const TripCardGridItem({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isTripLiked(trip.id),
      builder: (context, snapshot) {
        bool isLiked = snapshot.data ?? false;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (e) => MyDetailPlace(trip: trip)),
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(trip.imagePath, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatefulBuilder(
                      builder:
                          (context, setState) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isLiked
                                        ? Colors.red
                                        : Colors.black.withOpacity(0.5),
                              ),
                              onPressed: () async {
                                if (isLiked) {
                                  await unlikeTrip(trip.id, context);
                                } else {
                                  await likeTrip(trip.id);
                                }
                                setState(() {
                                  isLiked = !isLiked;
                                });
                              },
                            ),
                          ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      color: tdwhite.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            trip.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: tdwhite,
                            ),
                          ),
                          Text(
                            trip.daerah,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: tdwhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
