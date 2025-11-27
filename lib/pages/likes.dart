import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/tripProvider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/listTrip.dart';

class MyLikesPage extends StatefulWidget {
  const MyLikesPage({super.key});

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ListTrip> likedTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLikedTrips();
  }

  Future<void> fetchLikedTrips() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final likesSnapshot =
          await _firestore
              .collection('likes')
              .where('userId', isEqualTo: uid)
              .get();

      // Ambil list ID tempat yang disukai
      final likedIds =
          likesSnapshot.docs
              .map((doc) => doc['placeId'] as String?)
              .whereType<String>()
              .toList();

      final destinationsSnapshot =
          await _firestore.collection('destinations').get();
      final trips =
          destinationsSnapshot.docs
              .map((doc) => ListTrip.fromMap(doc.data()))
              .where((trip) => likedIds.contains(trip.id))
              .toList();

      setState(() {
        likedTrips = trips;
        isLoading = false;
      });

      // Mark as seen (clears new likes indicator)
      final tripProvider = Provider.of<MytripProvider>(context, listen: false);
      await tripProvider.markLikesSeen();

      print("✅ Total liked trips: ${trips.length}");
    } catch (e) {
      print('❌ Error fetching liked trips: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Delay untuk simulasi proses refresh
    await fetchLikedTrips(); // Memanggil fungsi untuk mengambil data trip yang disukai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Liked Trips")),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : likedTrips.isEmpty
                ? const Center(child: Text("Belum ada trip yang disukai."))
                : ListView.builder(
                  itemCount: likedTrips.length,
                  itemBuilder: (context, index) {
                    return TripCardSlidableItem(
                      trip: likedTrips[index],
                      onLikeChanged: () {
                        fetchLikedTrips();
                      },
                    );
                  },
                ),
      ),
    );
  }
}

class TripCardSlidableItem extends StatefulWidget {
  final ListTrip trip;
  final VoidCallback onLikeChanged;

  const TripCardSlidableItem({
    super.key,
    required this.trip,
    required this.onLikeChanged,
  });

  @override
  State<TripCardSlidableItem> createState() => _TripCardSlidableItemState();
}

class _TripCardSlidableItemState extends State<TripCardSlidableItem> {
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

  void _toggleLike() async {
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

      widget.onLikeChanged();
    } catch (e) {
      cutomeSneakBar(context, "Terjadi kesalahan saat update like");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.trip.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _toggleLike(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: isLiked ? 'Unlike' : 'Like',
          ),
        ],
      ),
      child: GestureDetector(
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 120, // <-- Tambahkan tinggi tetap di sini
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.network(
                    widget.trip.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                // Semi-transparent overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
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
                ),
                // Text
                Positioned(
                  left: 16,
                  bottom: 12,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.trip.daerah,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
