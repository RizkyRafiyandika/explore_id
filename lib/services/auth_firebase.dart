import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user currently logged in.");
      }

      String uid = user.uid;

      // 1. Delete all events created by user
      var eventsSnapshot =
          await _firestore
              .collection('events')
              .where('userId', isEqualTo: uid)
              .get();
      for (var doc in eventsSnapshot.docs) {
        await doc.reference.delete();
      }

      var likesSnapshot =
          await _firestore
              .collection('likes')
              .where('userId', isEqualTo: uid)
              .get();
      for (var doc in likesSnapshot.docs) {
        await doc.reference.delete();
      }

      var commentsSnapshot =
          await _firestore
              .collection('comments')
              .where('userId', isEqualTo: uid)
              .get();
      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('$uid.jpg');
        await storageRef.delete();
      } catch (e) {
        print("Error deleting profile image (might not exist): $e");
      }

      await _firestore.collection('users').doc(uid).delete();

      await user.delete();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Untuk mengamankan akun, Anda perlu login ulang sebelum dapat menghapus akun Anda. Silakan sign out lalu login kembali.',
        );
      }
      rethrow;
    } catch (e) {
      print("Error deleting account: $e");
      rethrow;
    }
  }
}
