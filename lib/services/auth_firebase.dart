import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<User?> signUpWithEmailAndPass(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "email": email,
          "username": username,
          "id": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });
        return user;
      }
    } catch (e) {
      print("Error during sign up: $e");
    }
    return null;
  }

  // Sign In User
  Future<User?> signInWithEmailAndPass(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error during sign in: $e");
      return null;
    }
  }

  // Logout User
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
