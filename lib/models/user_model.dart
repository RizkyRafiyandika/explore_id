import 'package:cloud_firestore/cloud_firestore.dart';

/// Model pengguna dengan field role untuk role-based access control
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? role; // "user" atau "admin"
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.role,
    this.profileImage,
    required this.createdAt,
  });

  /// Konversi dari Firestore document ke UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      username: data['username'] ?? 'Unknown',
      email: data['email'] ?? 'unknown@example.com',
      role: data['role'], // null jika belum dipilih
      profileImage: data['profileImage'],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  /// Konversi UserModel ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with method untuk membuat instance baru dengan beberapa field yang diubah
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, username: $username, email: $email, role: $role)';
}
