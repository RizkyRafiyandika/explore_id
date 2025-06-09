import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TripCardGridItem extends StatefulWidget {
  final ListTrip trip;

  const TripCardGridItem({super.key, required this.trip});

  @override
  State<TripCardGridItem> createState() => _TripCardGridItemState();
}

class _TripCardGridItemState extends State<TripCardGridItem>
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

    // Sinkron animasi dengan status isLiked setiap build
    if (_composition != null) {
      if (isLiked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    return GestureDetector(
      onTap: () {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          cutomeSneakBar(context, "Silahkan login terlebih dahulu");
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (e) => MyDetailPlace(trip: widget.trip)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(widget.trip.imagePath, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: _handleLike,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Lottie.network(
                        'https://lottie.host/7781efb5-1083-4c60-9dae-7c623b8bc977/kybz2woMOP.json',
                        controller: _controller,
                        onLoaded: (composition) {
                          _composition = composition;
                          _controller.duration = composition.duration;

                          // // Set posisi awal animasi sesuai status like
                          if (isLiked) {
                            _controller.forward();
                          } else {
                            _controller.forward();
                          }
                        },
                        repeat: false,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.trip.name,
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
                        widget.trip.daerah,
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
  }
}
