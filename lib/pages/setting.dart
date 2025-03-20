import 'package:explore_id/pages/sign_in.dart';
import 'package:explore_id/services/auth_firebase.dart';
import 'package:flutter/material.dart';

class MySettingPage extends StatelessWidget {
  MySettingPage({super.key});

  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          // Section: General
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

          const Divider(), // Garis pemisah
          // Section: Account
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            subtitle: const Text("Update your password"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            subtitle: const Text("Sign out from the app"),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyLogin()),
                (route) => false, // Kembali ke Login
              );
            },
          ),
        ],
      ),
    );
  }
}
