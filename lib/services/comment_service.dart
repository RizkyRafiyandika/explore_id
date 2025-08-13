import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/models/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:explore_id/widget/customeToast.dart';

// Menambahkan komentar
Future<void> addComment(String placeId, String commentText) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final commentDocId = '${placeId}_${commentText}';
  final commentRef = FirebaseFirestore.instance
      .collection('comments')
      .doc(commentDocId);

  await commentRef.set({
    'userId': user.uid,
    'placeId': placeId,
    'commentText': commentText,
    'timestamp': FieldValue.serverTimestamp(),
  });

  customToast("Komentar berhasil ditambahkan");
}

// Mengambil semua komentar untuk suatu tempat
Stream<List<Comment>> getCommentsStream(String placeId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .where('placeId', isEqualTo: placeId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => Comment.fromDoc(doc.id, doc.data()))
                .toList(),
      );
}

Future<String> getUsername(String userId) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!userDoc.exists) return "Unknown";
  return userDoc.data()?['username'] ?? "Unknown";
}

List<Comment> sortComments(List<Comment> comments) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return comments;

  comments.sort((a, b) {
    if (a.userId == currentUserId && b.userId != currentUserId) {
      return -1; // a di atas
    } else if (a.userId != currentUserId && b.userId == currentUserId) {
      return 1; // b di atas
    } else {
      return b.timestamp.compareTo(
        a.timestamp,
      );
    }
  });

  return comments;
}

// Menghapus komentar (opsional: hanya bisa dihapus user yang sama)
Future<void> deleteComment(String commentId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final commentRef = FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId);
  final docSnapshot = await commentRef.get();

  if (docSnapshot.exists && docSnapshot['userId'] == user.uid) {
    await commentRef.delete();
    customToast("Komentar berhasil dihapus");
  }
}
