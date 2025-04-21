import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> likeTrip(String placeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final likesRef = FirebaseFirestore.instance.collection('likes');

  // Cek apakah user sudah like tempat ini
  final snapshot =
      await likesRef
          .where('userId', isEqualTo: user.uid)
          .where('placeId', isEqualTo: placeId)
          .get();

  if (snapshot.docs.isEmpty) {
    // Kalau belum like, tambahkan like
    await likesRef.add({
      'userId': user.uid,
      'placeId': placeId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    customToast("Berhasil Menambakahan Tempat ke daftar suka");
  }
}

Future<void> unlikeTrip(String placeId, BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final likesRef = FirebaseFirestore.instance.collection('likes');

  final snapshot =
      await likesRef
          .where('userId', isEqualTo: user.uid)
          .where('placeId', isEqualTo: placeId)
          .get();

  for (var doc in snapshot.docs) {
    await doc.reference.delete(); // hapus like yang ditemukan
  }
  // Tampilkan notifikasi bahwa unlike berhasil
  customToast("Berhasil menghapus trip dari daftar suka");
}

Future<bool> isTripLiked(String placeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final snapshot =
      await FirebaseFirestore.instance
          .collection('likes')
          .where('userId', isEqualTo: user.uid)
          .where('placeId', isEqualTo: placeId)
          .get();

  return snapshot.docs.isNotEmpty;
}
