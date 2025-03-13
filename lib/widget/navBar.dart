import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/calender.dart';
import 'package:explore_id/pages/home.dart';
import 'package:explore_id/pages/plan.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [MyHome(), MyPlan(), MyCalender(), MyProfile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Menampilkan halaman berdasarkan index yang dipilih
          _pages[_selectedIndex],

          // Floating Navbar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CurvedNavigationBar(
                backgroundColor: Colors.transparent,
                color: tdcyan.withOpacity(0.9),
                buttonBackgroundColor: tdcyan,
                height: 60,
                index: _selectedIndex, // Menandai index aktif
                items: <Widget>[
                  Image.asset("assets/icons/home.png", width: 30, height: 30),
                  Image.asset("assets/icons/book.png", width: 30, height: 30),
                  Image.asset(
                    "assets/icons/calender.png",
                    width: 30,
                    height: 30,
                  ),
                  Image.asset("assets/icons/person.png", width: 30, height: 30),
                ],
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
