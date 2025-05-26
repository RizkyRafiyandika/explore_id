import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/calender.dart';
import 'package:explore_id/pages/home.dart';
import 'package:explore_id/pages/plan.dart';
import 'package:explore_id/pages/profile.dart';
import 'package:explore_id/pages/sign_in.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';

class NavBar extends StatefulWidget {
  final int selectedIndex;
  const NavBar({super.key, this.selectedIndex = 0});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex;
  final List<Widget> _pages = [MyHome(), MyPlan(), MyCalendar(), MyProfile()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    // Cek jika user menuju halaman Plan (index 1) atau Calendar (index 2)
    if (index == 1 || index == 2 || index == 3) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) {
        _showLoginAlert();
        return;
      }
    }

    // Jika lolos validasi, update index
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 10),
                const Text('Login Diperlukan'),
              ],
            ),
            content: const Text(
              'Silakan login terlebih dahulu untuk mengakses fitur ini.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (e) => MySignIn()),
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
                index: _selectedIndex,
                items: <Widget>[
                  Image.asset("assets/icons/home.png", width: 30, height: 30),
                  Image.asset("assets/icons/book.png", width: 30, height: 30),
                  Image.asset(
                    "assets/icons/calender.png",
                    width: 30,
                    height: 30,
                  ),
                  Consumer<MyUserProvider>(
                    builder: (context, provider, child) {
                      return CircleAvatar(
                        radius: 15,
                        backgroundColor: tdwhite,
                        backgroundImage:
                            provider.imageFile != null
                                ? FileImage(provider.imageFile!)
                                : AssetImage("assets/profile_pic.jpg"),
                      );
                    },
                  ),
                ],
                onTap: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
