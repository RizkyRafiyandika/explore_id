import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/custome_Bottom_submit.dart';
import 'package:explore_id/models/category.dart';
import 'package:explore_id/pages/likes.dart';
import 'package:explore_id/features/profile/screens/profile_screen.dart';
import 'package:explore_id/pages/browser.dart';
import 'package:explore_id/pages/plan_helper/plan_helper.dart';
import 'package:explore_id/pages/selectCategory.dart';
import 'package:explore_id/pages/sign_in.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/features/profile/providers/user_provider.dart';
import 'package:explore_id/widget/carousel.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:explore_id/widget/calendar_event_bottom_sheet.dart';
import 'package:explore_id/services/event_Service.dart';
// listTripCard removed from home as search contains the full list
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool isLoading = true;
  List<Event> todaysEvents = [];
  StreamSubscription<QuerySnapshot>? _homeEventsSub;

  @override
  void initState() {
    super.initState();

    // 🔽 Muat semua data trip dari provider
    Future.delayed(Duration.zero, () async {
      final tripProvider = Provider.of<MytripProvider>(context, listen: false);
      final userProvider = Provider.of<MyUserProvider>(context, listen: false);
      userProvider.fetchUserData();
      tripProvider.fetchLikeStatus();
      await userProvider.fetchUserData();
      await Future.wait([
        tripProvider.loadTripsFromFirestore(),
        Future.delayed(Duration(seconds: 1)),
      ]);
      setState(() {
        isLoading = false;
      });
    });

    // Setup events stream for today's activities
    _setupHomeEventsStream();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1)); // contoh delay
    final tripProvider = Provider.of<MytripProvider>(context, listen: false);
    tripProvider.loadTripsFromFirestore();
  }

  @override
  void dispose() {
    _homeEventsSub?.cancel();
    super.dispose();
  }

  void _setupHomeEventsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    _homeEventsSub = FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            final List<Event> events =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return Event(
                    id: data['id'],
                    title: data['title'],
                    desk: data['desk'] ?? '',
                    endDate: (data['endDate'] as Timestamp).toDate(),
                    date: (data['date'] as Timestamp).toDate(),
                    start: data['start'] ?? '',
                    end: data['end'] ?? '',
                    place: data['place'] ?? '',
                    label: data['label'] ?? '',
                    docId: doc.id,
                    isCheck: (data['isCheck'] ?? data['ischeck']) is bool
                        ? (data['isCheck'] ?? data['ischeck'])
                        : false,
                  );
                }).toList();

            final today = DateTime.now();
            final dateOnly = DateTime(today.year, today.month, today.day);
            final filtered =
                events.where((e) {
                  final d = DateTime(e.date.year, e.date.month, e.date.day);
                  return d == dateOnly;
                }).toList();

            if (mounted) {
              setState(() {
                todaysEvents = filtered;
              });
            }
          },
          onError: (e) {
            print('Error fetching home events: $e');
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    // Use provider where necessary via Consumer; trips are shown in search and browser pages
    final user = FirebaseAuth.instance.currentUser;

    // Cek apakah user tidak login atau login anonim
    final displayUsername =
        (user == null || user.isAnonymous) ? "Guest" : userProvider.username;

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: _MyAppBar(context, displayUsername, user),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Carousel
              Skeletonizer(enabled: isLoading, child: ListExplore()),
              
              const SizedBox(height: 20),
              
              // Search bar
              Skeletonizer(enabled: isLoading, child: _SearchBar(context)),
              
              const SizedBox(height: 32),
              
              // Category
              Skeletonizer(enabled: isLoading, child: _ListCategory()),

              const SizedBox(height: 16),

              // Plan Dream Trip Card
              Skeletonizer(
                enabled: isLoading,
                child: _planDreamTripCard(context),
              ),

              // Today's Activity Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Today's Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Today's Activity Cards
              Skeletonizer(
                enabled: isLoading,
                child: _todayActivitySection(todaysEvents: todaysEvents),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- Today's Activity Section --------------------
Widget _todayActivitySection({required List<Event> todaysEvents}) {
  if (todaysEvents.isEmpty) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'No activities for today',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: todaysEvents.length,
    separatorBuilder: (context, index) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final e = todaysEvents[index];
      return GestureDetector(
        onTap: () => showCalendarEventBottomSheet(context, e),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade50),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: e.isCheck ? Colors.green.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  e.isCheck ? Icons.check_circle_rounded : Icons.directions_walk,
                  color: e.isCheck ? Colors.green.shade400 : Colors.blue.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: e.isCheck ? TextDecoration.lineThrough : null,
                        color: e.isCheck ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${e.start} • ${e.place}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        decoration: e.isCheck ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: e.isCheck ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: e.isCheck ? Colors.green.shade100 : Colors.orange.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      e.isCheck ? "DONE" : "IN",
                      style: TextStyle(
                        color: e.isCheck ? Colors.green.shade800 : Colors.orange.shade800,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (!e.isCheck)
                      Text(
                        "PROGRESS",
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _planDreamTripCard(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [tdcyan, tdcyan.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: tdcyan.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Plan Your Dream Trip",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Get AI-powered recommendations for your next adventure.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanHelper()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: tdcyan,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Start Planning",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}


Widget _ListCategory() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Category",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isMore = category.imagePath.isEmpty;
              return GestureDetector(
                onTap: () {
                  if (isMore) {
                    // Tampilkan dialog kategori lainnya
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: tdwhite,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("More Categories"),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: moreCategories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemBuilder: (context, index) {
                                final item = moreCategories[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context); // Tutup dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MySelectCategory(
                                              categoryName: item.name,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue.shade50,
                                        radius: 25,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Image.asset(
                                            item.imagePath,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // Navigasi langsung ke kategori
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                MySelectCategory(categoryName: category.name),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child:
                            isMore
                                ? const Icon(
                                  Icons.grid_view,
                                  size: 30,
                                  color: Colors.blue,
                                )
                                : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    category.imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(category.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

Container _SearchBar(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyBrowser()),
                );
              },
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  hintText: "Where to next?",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: tdcyan,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: tdcyan.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    ),
  );
}

AppBar _MyAppBar(BuildContext context, String username, User? user) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    elevation: 0,
    toolbarHeight: 90,
    title: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Silakan login untuk melihat profil.")),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
              }
            },
            child: Consumer<MyUserProvider>(
              builder: (context, provider, child) {
                return Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade100, width: 2),
                    image: DecorationImage(
                      image: provider.imageFile == null
                          ? const AssetImage("assets/profile_pic.jpg")
                          : FileImage(provider.imageFile!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "WELCOME BACK",
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: tdcyan,
                ),
              ),
            ],
          ),
          const Spacer(),
          user == null
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MySignIn()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: tdcyan, fontWeight: FontWeight.w600),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyLikesPage()),
                    );
                  },
                  child: Consumer<MytripProvider>(
                    builder: (context, tripProvider, child) => Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                        if (tripProvider.hasNewLikes)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
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
}
