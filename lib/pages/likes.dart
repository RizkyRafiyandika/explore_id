import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

      // Filter dari ListTrips lokal berdasarkan id yang di-like
      final trips =
          ListTrips.where((trip) => likedIds.contains(trip.id)).toList();

      setState(() {
        likedTrips = trips;
        isLoading = false;
      });

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
                    return TripCardGridItem(trip: likedTrips[index]);
                  },
                ),
      ),
    );
  }
}
