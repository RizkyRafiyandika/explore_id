import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/dataChartTrip.dart';
import 'package:explore_id/pages/setting.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:explore_id/widget/Indicator.dart';
import 'package:explore_id/widget/cartContoller.dart';
import 'package:explore_id/widget/pie_chart.dart'; // pastikan getSections() berasal dari sini
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile>
    with SingleTickerProviderStateMixin {
  late int touchIndex = -1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      generateChartData(currentUser.uid).then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    final displayUsername =
        (user == null || user.isAnonymous) ? "Guest" : userProvider.username;

    final displayEmail =
        (user == null || user.isAnonymous) ? "No email" : userProvider.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tdcyan,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (e) => MySettingPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 9,
            child: Container(color: tdcyan),
          ),

          // Lengkungan pemisah
          Positioned(
            top: MediaQuery.of(context).size.height / 9 - 70,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipperUp(),
              child: Container(height: 100, color: tdcyan),
            ),
          ),

          // Konten profil
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 20,
            ),
            child: Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_pic.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayUsername,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    displayEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Pie Chart
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chartData.isEmpty
                    ? const Center(child: Text("Belum ada data perjalanan."))
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        AnimatedPieChart(getSections: getSections),
                        const MyIndicatorWidget(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

// Clipper untuk efek gelombang ke atas
class WaveClipperUp extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 50,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
