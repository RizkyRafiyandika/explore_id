import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
          "role": null, // Role akan diisi setelah user memilih role atau login
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

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection("users").doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection("users").doc(user.uid).set({
            "email": user.email,
            "username": user.displayName ?? "Unknown",
            "id": user.uid,
            "createdAt": FieldValue.serverTimestamp(),
          });
        }
      }
      return userCredential;
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  // Facebook Sign In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot userDoc =
              await _firestore.collection("users").doc(user.uid).get();
          if (!userDoc.exists) {
            await _firestore.collection("users").doc(user.uid).set({
              "email": user.email,
              "username": user.displayName ?? "Unknown",
              "id": user.uid,
              "createdAt": FieldValue.serverTimestamp(),
            });
          }
        }
        return userCredential;
      } else {
        print("Facebook sign-in failed: ${result.status}");
        return null;
      }
    } catch (e) {
      print("Error during Facebook sign-in: $e");
      return null;
    }
  }

  // Check if user exists in Firestore
  Future<bool> isUserInFirestore(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      return doc.exists;
    } catch (e) {
      print("Error checking user in Firestore: $e");
      return false;
    }
  }

  // Logout User
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
