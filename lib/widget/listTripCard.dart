import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:explore_id/models/listTrip.dart';

class TripCardGridItem extends StatefulWidget {
  final ListTrip trip;
  final VoidCallback onLikeChanged; // Callback ke parent

  const TripCardGridItem({
    super.key,
    required this.trip,
    required this.onLikeChanged,
  });

  @override
  State<TripCardGridItem> createState() => _TripCardGridItemState();
}

class _TripCardGridItemState extends State<TripCardGridItem> {
  late bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final status = await isTripLiked(widget.trip.id);
    setState(() {
      isLiked = status;
    });
  }

  void _handleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      cutomeSneakBar(context, "Silahkan login terlebih dahulu");
      return;
    }

    try {
      if (isLiked) {
        await unlikeTrip(widget.trip.id);
      } else {
        await likeTrip(widget.trip.id);
      }

      setState(() {
        isLiked = !isLiked;
      });

      widget.onLikeChanged(); // Trigger refresh in parent if needed
    } catch (e) {
      // ignore: use_build_context_synchronously
      cutomeSneakBar(context, "Terjadi kesalahan, coba lagi");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color:
                          isLiked ? Colors.red : Colors.black.withOpacity(0.5),
                    ),
                    onPressed: _handleLike,
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
