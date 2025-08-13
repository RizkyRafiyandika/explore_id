import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String commentText;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.commentText,
    required this.timestamp,
  });

  factory Comment.fromDoc(String docId, Map<String, dynamic> data) {
    return Comment(
      id: docId,
      userId: data['userId'] ?? '',
      commentText: data['commentText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
