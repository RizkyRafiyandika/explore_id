import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> likeTrip(String placeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final likeDocId = '${user.uid}_$placeId';
  final likeRef = FirebaseFirestore.instance.collection('likes').doc(likeDocId);

  final docSnapshot = await likeRef.get();
  if (!docSnapshot.exists) {
    await likeRef.set({
      'userId': user.uid,
      'placeId': placeId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    customToast("Berhasil menambahkan tempat ke daftar suka");
  }
}

Future<void> unlikeTrip(String placeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final likeDocId = '${user.uid}_$placeId';
  final likeRef = FirebaseFirestore.instance.collection('likes').doc(likeDocId);

  final docSnapshot = await likeRef.get();
  if (docSnapshot.exists) {
    await likeRef.delete();
    customToast("Berhasil menghapus trip dari daftar suka");
  }
}

Future<bool> isTripLiked(String placeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final likeDocId = '${user.uid}_$placeId';
  final likeRef = FirebaseFirestore.instance.collection('likes').doc(likeDocId);

  final docSnapshot = await likeRef.get();
  return docSnapshot.exists;
}

Future<int> getTotalLikesForTrip(String placeId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('likes')
      .where('placeId', isEqualTo: placeId)
      .get();

  return snapshot.size;
}
