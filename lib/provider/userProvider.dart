import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUserProvider with ChangeNotifier {
  String _username = "Guest1";
  String _email = "guest@example.com"; // Default email

  String get username => _username;
  String get email => _email;

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        if (userDoc.exists) {
          _username = userDoc["username"];
          _email = userDoc["email"];
          notifyListeners(); // Update UI jika ada perubahan
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }
}
