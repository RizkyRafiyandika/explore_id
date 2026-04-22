import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ListExplore extends StatefulWidget {
  const ListExplore({super.key});

  @override
  _ListExploreState createState() => _ListExploreState();
}

class _ListExploreState extends State<ListExplore> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tripProvider = Provider.of<MytripProvider>(context, listen: false);
      await tripProvider.loadTripsFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<MytripProvider>(context);
    final isLoading = tripProvider.allTrip.isEmpty;
    final selectedTrips = tripProvider.selectedTrips;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 380,
                autoPlay: true,
                viewportFraction: 0.75,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
              ),
              items:
                  selectedTrips.map((trip) {
                    return CarouselCardItem(trip: trip);
                  }).toList(),
            ),
          ],
        );
  }
}

class CarouselCardItem extends StatefulWidget {
  final ListTrip trip;
  const CarouselCardItem({super.key, required this.trip});

  @override
  State<CarouselCardItem> createState() => _CarouselCardItemState();
}

class _CarouselCardItemState extends State<CarouselCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  LottieComposition? _composition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLike() async {
    final tripProvider = Provider.of<MytripProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      cutomeSneakBar(context, "Silahkan login terlebih dahulu");
      return;
    }

    try {
      await tripProvider.toggleLike(widget.trip.id);
    } catch (e) {
      cutomeSneakBar(context, "Terjadi kesalahan, coba lagi");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<MytripProvider>(context);
    final isLiked = tripProvider.isTripLikedLocal(widget.trip.id);

    if (_composition != null) {
      if (isLiked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyDetailPlace(trip: widget.trip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(widget.trip.imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Smooth gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.4, 0.8],
                ),
              ),
            ),

            // Like Button (Lottie)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _handleLike,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.network(
                    'https://lottie.host/7781efb5-1083-4c60-9dae-7c623b8bc977/kybz2woMOP.json',
                    controller: _controller,
                    onLoaded: (composition) {
                      _composition = composition;
                      _controller.duration = composition.duration;
                      if (isLiked) {
                        _controller.value = 1.0;
                      } else {
                        _controller.value = 0.0;
                      }
                    },
                    repeat: false,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Location Row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.trip.daerah,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Destination Name
                  Text(
                    widget.trip.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Rating and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          const Text(
                            "4.9",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Price
                      Text(
                        "Rp ${widget.trip.harga.toStringAsFixed(0)}/day",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
