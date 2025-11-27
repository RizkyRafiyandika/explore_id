import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/category.dart';
import 'package:explore_id/pages/likes.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:explore_id/pages/browser.dart';
import 'package:explore_id/pages/selectCategory.dart';
import 'package:explore_id/pages/sign_in.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:explore_id/widget/carousel.dart';
import 'package:explore_id/widget/customeToast.dart';
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
                    date: (data['date'] as Timestamp).toDate(),
                    start: data['start'] ?? '',
                    end: data['end'] ?? '',
                    place: data['place'] ?? '',
                    label: data['label'] ?? '',
                    docId: doc.id,
                    isCheck: data['isCheck'] is bool ? data['isCheck'] : false,
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
              // Carousel skeleton
              Skeletonizer(enabled: isLoading, child: ListExplore()),
              // Search bar skeleton
              Skeletonizer(enabled: isLoading, child: _SearchBar(context)),
              SizedBox(height: 20),
              // Category skeleton
              Skeletonizer(enabled: isLoading, child: _ListCategory()),
              // Title skeleton
              Skeletonizer(enabled: isLoading, child: _title_ListTrip()),
              // Today's Activity
              Skeletonizer(
                enabled: isLoading,
                child: _todayActivitySection(todaysEvents: todaysEvents),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- Today's Activity Section --------------------
Widget _todayActivitySection({required List<Event> todaysEvents}) {
  final total = todaysEvents.length;
  final completed = todaysEvents.where((e) => e.isCheck).length;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tdcyan.withOpacity(0.1), tdcyan.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tdcyan.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tdcyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      total > 0
                          ? '$completed of $total completed'
                          : 'No events today',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        completed == total ? const Color(0xFF10B981) : tdcyan,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${((completed / total) * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // List
        todaysEvents.isEmpty
            ? Container(
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  const Text(
                    'No activities for today',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todaysEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final e = todaysEvents[index];
                return _buildHomeEventCard(e);
              },
            ),
      ],
    ),
  );
}

Widget _buildHomeEventCard(Event e) {
  Color labelColor;
  switch (e.label.toLowerCase()) {
    case 'work':
      labelColor = const Color(0xFF6366F1);
      break;
    case 'personal':
      labelColor = const Color(0xFF10B981);
      break;
    case 'travel':
      labelColor = const Color(0xFFF59E0B);
      break;
    case 'health':
      labelColor = const Color(0xFFEF4444);
      break;
    default:
      labelColor = tdcyan;
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: labelColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.place, color: labelColor, size: 22),
      ),
      title: Text(
        e.place,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: e.isCheck ? Colors.black54 : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(e.title, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            '${e.start} - ${e.end}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      trailing:
          e.isCheck ? Icon(Icons.check_circle, color: Colors.green) : null,
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
                          backgroundColor: tdcyanwhite.withOpacity(0.9),
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
    margin: const EdgeInsets.only(top: 16, left: 30, right: 30),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
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
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: "Search your destination here...",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 186, 186, 186),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: tdcyan,
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBrowser()),
              );
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

AppBar _MyAppBar(BuildContext context, String username, User? user) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Row(
      children: [
        GestureDetector(
          onTap: () {
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Silakan login untuk melihat profil.")),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfile()),
              );
            }
          },
          child: Consumer<MyUserProvider>(
            builder: (context, provider, child) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image:
                        provider.imageFile == null
                            ? const AssetImage("assets/profile_pic.jpg")
                            : FileImage(provider.imageFile!) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12), // Spasi antar avatar dan teks
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi $username",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Text(
              "Where Do You Want To Go",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Spacer(),
        user == null
            ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MySignIn()),
                );
              },
              child: Text(
                "Login",
                style: TextStyle(color: tdcyan, fontWeight: FontWeight.w500),
              ),
            )
            : GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyLikesPage()),
                );
              },
              child: Consumer<MytripProvider>(
                builder:
                    (context, tripProvider, child) => Stack(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          weight: 30,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        if (tripProvider.hasNewLikes)
                          Positioned(
                            right: 0,
                            top: 0,
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
  );
}

class _title_ListTrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            "Today's Activity",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              cutomeSneakBar(
                context,
                "Silahkan login terlebih dahulu untuk melihat semua trip",
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBrowser()),
              );
            }
          },
          child: Text(
            "View All",
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
