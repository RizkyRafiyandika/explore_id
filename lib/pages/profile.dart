import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/dataChartTrip.dart';
import 'package:explore_id/pages/ediProfile.dart';
import 'package:explore_id/pages/setting.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:explore_id/services/chart_count.dart';
import 'package:explore_id/widget/Indicator.dart';
import 'package:explore_id/widget/cartContoller.dart';
import 'package:explore_id/widget/graphBar.dart';
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
  //
  late int touchIndex = -1;
  bool isLoading = true;
  late Future<List<double>> futureData;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      futureData = getMonthlyVisitCounts(currentUser.uid);
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
        title: const Text("My Account", style: TextStyle(color: Colors.white)),
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
          // Bagian atas background
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

          // Konten profil TETAP (tidak ikut scroll)
          Positioned(
            top: MediaQuery.of(context).size.height / 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Consumer<MyUserProvider>(
                      builder: (context, provider, child) {
                        return CircleAvatar(
                          backgroundImage:
                              provider.imageFile != null
                                  ? FileImage(provider.imageFile!)
                                  : AssetImage('assets/profile_pic.jpg')
                                      as ImageProvider,
                          radius: 50,
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      right: 4,
                      child: InkWell(
                        onTap: () async {
                          final provider = await Provider.of<MyUserProvider>(
                            context,
                            listen: false,
                          );
                          _showImageBar(context, provider);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tdcyan,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: tdwhitepure,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
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

          // Scrollable content (chart + tombol)
          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: tdwhite.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MyIndicatorWidget(),
                    ),
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : chartData.isEmpty
                      ? const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Belum ada data perjalanan."),
                        ),
                      )
                      : AnimatedPieChart(getSections: getSections),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        "Monthly Summary",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: tdorange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<List<double>>(
                      future: futureData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          print(snapshot.error);
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Tidak ada data bulanan."),
                          );
                        } else {
                          // Tidak perlu await di sini
                          return MyGraphBar(monthlySummary: snapshot.data!);
                        }
                      },
                    ),
                  ),

                  // Tombol-tombol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tombol Sosmed
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Media Sosial'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('📱 WhatsApp: +62 812-3456-7890'),
                                    SizedBox(height: 8),
                                    Text('📸 Instagram: @yourusername'),
                                    SizedBox(height: 8),
                                    Text('✉️ Email: your@email.com'),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: tdcyan,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Icon(Icons.share, color: Colors.white, size: 24),
                              Text(
                                "Social Media",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol Edit
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyEditProfile(),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: tdorange,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Icon(Icons.edit, color: Colors.white, size: 24),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showImageBar(BuildContext context, MyUserProvider provider) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () async {
                await provider.uploadImageCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                await provider.pickImageGalery();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Batal'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
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
