import 'package:carousel_slider/carousel_slider.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/category.dart';
import 'package:explore_id/models/explore.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/nearby_List_Page.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:explore_id/provider/userProvider.dart';
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: _MyAppBar(context, userProvider.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ListExplore(),
            _SearchBar(searchController),
            SizedBox(height: 16),
            _ListCategory(),
            _title_ListTrip(),
            _ListTrip(trips: filteredTrips),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

Padding _ListCategory() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SizedBox(
      height: 120, // Tinggi ListView
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // **ListView Horizontal**
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfile()),
              );
            },
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // **Membuat gambar bulat**
                    image: DecorationImage(
                      image: AssetImage(
                        category.imagePath,
                      ), // **Gambar dari assets**
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  category.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Container _SearchBar(searchController) {
  return Container(
    margin: const EdgeInsets.only(top: 16, left: 30, right: 30),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: searchController, // Tambahkan controller

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(10),
        hintText: "Search Here", // Pastikan ini bukan typo
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 186, 186, 186),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset("assets/icons/search.png"),
        ),
        suffixIcon: Container(
          width: 100,
          child: IntrinsicHeight(
            child: Row(mainAxisAlignment: MainAxisAlignment.end),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

Padding _ListExplore() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: CarouselSlider.builder(
      itemCount: exploreItems.length,
      options: CarouselOptions(
        height: 180, // Tinggi carousel
        autoPlay: true, // Otomatis geser
        enlargeCenterPage: true, // Membesarkan item tengah
        viewportFraction: 0.9, // Ukuran item dalam layar
        autoPlayInterval: Duration(seconds: 2), // Waktu antar geseran
      ),
      itemBuilder: (context, index, realIndex) {
        final item = exploreItems[index];

        return Container(
          width: double.infinity,
          height: 180,
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(item.picturePath, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 10,
                  left: 50,
                  right: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdcyan.withOpacity(0.8),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyProfile()),
                      );
                    },
                    child: Text(
                      item.buttonText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          child: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(
              "assets/profile_pic.jpg",
            ), // Sesuaikan nama file
          ),
        ),
        SizedBox(width: 10), // Spasi antar avatar dan teks
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi $username",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "Where Do You Want To Go",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Expanded(child: SizedBox()), // Membantu menjaga tata letak tetap rapi
        GestureDetector(
          onTap: () {
            print("ini Notif Page");
          },
          child: Image.asset(
            "assets/icons/notification.png",
            width: 30,
            height: 30,
          ),
        ),
      ],
    ),
  );
}

class _ListTrip extends StatelessWidget {
  final List<ListTrip> trips; // Tambahkan parameter untuk daftar trip

  _ListTrip({required this.trips}); // Constructor untuk menerima data

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
        itemCount: trips.length, // Gunakan daftar trip yang sudah difilter
        itemBuilder: (context, index) {
          final trip = trips[index];
          return GestureDetector(
            onTap: () {},
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
                      child: Image.asset(trip.imagePath, fit: BoxFit.fill),
                    ),
                    Positioned(
                      height: 100,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: tdwhite.withOpacity(0.1),
                        child: Column(
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
      ),
    );
  }
}

class _title_ListTrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "List Trip",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tdcyan,
            ),
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
