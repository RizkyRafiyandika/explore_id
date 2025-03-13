import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/category.dart';
import 'package:explore_id/models/explore.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 🔥 Tambahkan ini agar navbar tidak tertutupi
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: _MyAppBar(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ListExplore(),
            _SearchBar(),
            SizedBox(height: 16),
            _ListCategory(),
            _title_ListTrip(),
            _ListTrip(),
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
          return Column(
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
          );
        },
      ),
    ),
  );
}

Container _SearchBar() {
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
      // onChanged: (value) => _runFilter(value),
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
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exploreItems.length,
        itemBuilder: (context, index) {
          final item = exploreItems[index];

          return Container(
            width: 360,
            height: 180,
            margin: EdgeInsets.only(right: 10), // Jarak antar item
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(item.picturePath, fit: BoxFit.cover),
                  ),

                  Positioned(
                    bottom: 10, // Jarak dari bawah
                    left: 100, // Jarak dari kiri
                    right: 100, // Jarak dari kanan
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tdcyan.withOpacity(
                          0.8,
                        ), // Tombol semi-transparan
                        foregroundColor: Colors.black, // Warna teks
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
    ),
  );
}

AppBar _MyAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: tdwhite,
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
              "Hi Ven",
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true, // Penting agar GridView tidak error
        physics:
            NeverScrollableScrollPhysics(), // Matikan scroll agar hanya Column yang bisa scroll
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: ListTrips.length,
        itemBuilder: (context, index) {
          final trip = ListTrips[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(trip.imagePath, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 0, // Posisikan teks di bawah gambar
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Latar belakang transparan
                    child: Text(
                      trip.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Pastikan teks terbaca
                      ),
                    ),
                  ),
                ),
              ],
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(onPressed: () {}, child: Text("View All")),
      ],
    );
  }
}
