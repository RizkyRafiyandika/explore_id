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
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (e) => MyProfile()),
                );
              },
              child: CircleAvatar(
                radius: 20, // Atur ukuran foto profil
                backgroundImage: AssetImage("assets/Profile.png"),
              ),
            ),
          ),
        ],
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
