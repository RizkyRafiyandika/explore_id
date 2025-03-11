import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/explore.dart';
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // AppBar lebih tinggi
        child: _MyAppBar(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: SizedBox(
          height: 160, // Tinggi yang cukup untuk horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Buat horizontal
            itemCount: exploreItems.length,
            itemBuilder: (context, index) {
              final item = exploreItems[index];

              return Container(
                width: 250, // Lebar tiap item
                margin: EdgeInsets.only(right: 10), // Jarak antar item
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        width: 150,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(item.picturePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Button di atas gambar
                      Positioned(
                        bottom: 10, // Jarak dari bawah
                        left: 10, // Jarak dari kiri
                        right: 10, // Jarak dari kanan
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(
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
                              MaterialPageRoute(
                                builder: (context) => MyProfile(),
                              ),
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
              "assets/notification.png",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
