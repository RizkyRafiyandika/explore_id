import 'package:explore_id/pages/ediProfile.dart';
import 'package:explore_id/pages/sign_in.dart';
import 'package:explore_id/services/auth_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySettingPage extends StatelessWidget {
  MySettingPage({super.key});

  final FirebaseAuthService _auth = FirebaseAuthService();

  Future<bool> isGuestUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous; // Cek apakah pengguna guest
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<bool>(
        future: isGuestUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Tampilkan loading saat cek status
          }
          bool isGuest = snapshot.data ?? true;

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "General",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Notifications"),
                subtitle: const Text("Manage notification settings"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Language"),
                subtitle: const Text("Change app language"),
                onTap: () {},
              ),

              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Account",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                subtitle: const Text("Edit your profile"),
                onTap:
                    isGuest
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyEditProfile(),
                            ),
                          );
                        }, // Disable jika guest
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                subtitle: const Text("Update your password"),
                onTap: isGuest ? null : () {}, // Disable jika guest
              ),

              // 🔥 Perbaikan Login Button
              if (isGuest) // Hanya tampil jika user Guest
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text("Login"),
                  subtitle: const Text("Sign in with your account"),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MySignIn(),
                      ), // 🛠 Ubah ke MySignIn()
                    );
                  },
                ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                subtitle: const Text("Sign out from the app"),
                enabled: !isGuest, // Disabled jika guest
                onTap:
                    isGuest
                        ? null
                        : () async {
                          await _auth.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MySignIn()),
                            (route) => false,
                          );
                        },
              ),
            ],
          );
        },
      ),
    );
  }
}
