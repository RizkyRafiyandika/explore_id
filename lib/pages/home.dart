import 'package:carousel_slider/carousel_slider.dart';
import 'package:explore_id/models/category.dart';
import 'package:explore_id/models/explore.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/nearby_List_Page.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:explore_id/pages/selectCategory.dart';
import 'package:explore_id/provider/userProvider.dart';
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
  List<ListTrip> filteredTrips = ListTrips;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => _runFilter(searchController.text));

    // Ambil data user saat pertama kali widget dibuat
    Future.delayed(Duration.zero, () {
      Provider.of<MyUserProvider>(context, listen: false).fetchUserData();
    });
  }

  void _runFilter(String query) {
    if (query.isNotEmpty) {
      final trips =
          ListTrips.where(
            (trip) => trip.name.toLowerCase().contains(query.toLowerCase()),
          ).toList();
      setState(() {
        filteredTrips = trips;
      });
    } else {
      setState(() {
        filteredTrips = ListTrips;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1)); // contoh delay
    // TODO: Panggil ulang API atau setState() untuk reload data
    setState(() {
      // contoh: kamu bisa re-fetch data trip di sini
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    // Cek apakah user tidak login atau login anonim
    final displayUsername =
        (user == null || user.isAnonymous) ? "Guest" : userProvider.username;

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: _MyAppBar(context, displayUsername),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _ListExplore(),
              SizedBox(height: 15),
              _SearchBar(searchController),
              SizedBox(height: 20),
              _ListCategory(),
              _title_ListTrip(),
              ListTripWidget(trips: filteredTrips),
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
                          title: const Text("More Categories"),
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
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ],
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

Container _SearchBar(searchController) {
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
          child: IconButton(
            icon: const Icon(
              Icons.tune, // ikon filter
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              // Aksi saat tombol filter ditekan
            },
          ),
        ),
      ],
    ),
  );
}

Padding _ListExplore() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0), // kiri-kanan 16
    child: CarouselSlider(
      options: CarouselOptions(
        //buat atur besar penempatan carousel
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
      ),
      items:
          carouselItem.map((item) {
            //manggil carousel item seperti title subtitle dan image
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(item['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item['title']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              item['subtitle']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onPressed: () {},
                              child: Text('Explore Now'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
    ),
  );
}

AppBar _MyAppBar(BuildContext context, String username) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyProfile()),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/profile_pic.jpg"),
                fit: BoxFit.cover,
              ),
            ),
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
        GestureDetector(
          onTap: () {
            print("Notifikasi dibuka");
          },
          child: Stack(
            children: [
              Image.asset(
                "assets/icons/notification.png",
                width: 30,
                height: 30,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  //ganti container karena Class Circle avatar tidak memiliki widht dan height
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyNearbyPage()),
            );
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
