import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/category.dart';
import 'package:explore_id/pages/likes.dart';
import 'package:explore_id/pages/nearby_List_Page.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:explore_id/pages/selectCategory.dart';
import 'package:explore_id/pages/sign_in.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:explore_id/widget/carousel.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  TextEditingController searchController = TextEditingController();

  @override
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
      await tripProvider
          .loadTripsFromFirestore(); // Gantikan setTrips(ListTrips)
    });

    // 🔍 Jalankan filter setiap kali search text berubah
    searchController.addListener(() {
      final tripProvider = Provider.of<MytripProvider>(context, listen: false);
      tripProvider.runFilter(searchController.text);
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1)); // contoh delay
    final tripProvider = Provider.of<MytripProvider>(context, listen: false);
    tripProvider.loadTripsFromFirestore();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    final tripProvider = Provider.of<MytripProvider>(context);
    final trips = tripProvider.filteredTrip;
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
              ListExplore(),
              _SearchBar(context, searchController),
              SizedBox(height: 20),
              _ListCategory(),
              _title_ListTrip(),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),

                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return TripCardGridItem(trip: trips[index]);
                },
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
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

Container _SearchBar(BuildContext context, searchController) {
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
          child: TextField(
            controller: searchController,
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
        Container(
          margin: const EdgeInsets.only(
            left: 10,
          ), // Menambahkan jarak antara TextField dan IconButton
          decoration: BoxDecoration(
            color: Color(0xFF4DB5FF), // warna biru tombol filter
            borderRadius: BorderRadius.circular(15),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.tune, // ikon filter
              color: Colors.white,
              size: 20,
            ),
            onSelected: (value) {
              // Handle pilihan dropdown
              if (value == 'Nama') {
                // TODO: Filter populer
                Provider.of<MytripProvider>(
                  context,
                  listen: false,
                ).setFilterType(value);
              } else if (value == 'Daerah') {
                // TODO: Filter termurah
                Provider.of<MytripProvider>(
                  context,
                  listen: false,
                ).setFilterType(value);
              } else if (value == 'Category') {
                // TODO: Filter terdekat
                Provider.of<MytripProvider>(
                  context,
                  listen: false,
                ).setFilterType(value);
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(value: 'Nama', child: Text('Nama')),
                  const PopupMenuItem(value: 'Daerah', child: Text('Daerah')),
                  const PopupMenuItem(
                    value: 'Category',
                    child: Text('Category'),
                  ),
                ],
          ),
        ),
      ],
    ),
  );
}

AppBar _MyAppBar(BuildContext context, String username, User? user) {
  return AppBar(
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
              child: Stack(
                children: [
                  Icon(
                    Icons.favorite_border,
                    weight: 30,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
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
            "List Trip",
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyNearbyPage()),
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
