import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class MyUserProvider with ChangeNotifier {
  String _username = "Guest1";
  String _email = "guest@example.com";
  File? _imageFile;

  String get username => _username;
  String get email => _email;
  File? get imageFile => _imageFile;

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          _username = userDoc["username"];
          _email = userDoc["email"];
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> pickImageGalery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> uploadImageCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      _imageFile = File(pickedImage.path);
      notifyListeners();
    }
  }

  Future<String?> uploadImageToFirebase() async {
    if (_imageFile == null) return null;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Buat path file unik berdasarkan UID
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user.uid}.jpg');

      // Upload file ke Firebase Storage
      await storageRef.putFile(_imageFile!);

      // Ambil URL download file
      String downloadUrl = await storageRef.getDownloadURL();

      // Simpan URL ke Firestore (jika diperlukan)
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"profileImage": downloadUrl},
      );

      return downloadUrl;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
