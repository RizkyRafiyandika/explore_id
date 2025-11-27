import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk mengelola role pengguna di Firestore
class RoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Simpan role pengguna ke Firestore
  ///
  /// [userId]: UID pengguna dari Firebase Auth
  /// [role]: role pengguna ("user" atau "admin")
  Future<void> saveUserRole(String userId, String role) async {
    try {
      // Validasi role
      if (role != 'user' && role != 'admin') {
        throw Exception('Role harus "user" atau "admin"');
      }

      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ Role berhasil disimpan: $userId -> $role');
    } catch (e) {
      print('✗ Error menyimpan role: $e');
      rethrow;
    }
  }

  /// Ambil role pengguna dari Firestore
  ///
  /// [userId]: UID pengguna dari Firebase Auth
  /// Returns: Future<String?> - role pengguna atau null
  Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('✗ Error mengambil role: $e');
      return null;
    }
  }

  /// Validasi apakah role pengguna sesuai dengan expected role (untuk login)
  ///
  /// [userId]: UID pengguna
  /// [expectedRole]: role yang diharapkan
  /// Returns: Future<bool> - true jika sesuai, false jika tidak atau belum dipilih
  Future<bool> validateUserRole(String userId, String expectedRole) async {
    try {
      String? storedRole = await getUserRole(userId);

      if (storedRole == null) {
        print('⚠ Role belum dipilih untuk user: $userId');
        return false; // User belum memilih role
      }

      bool isValid = storedRole == expectedRole;
      if (!isValid) {
        print(
          '✗ Role validation failed: stored=$storedRole, expected=$expectedRole',
        );
      }
      return isValid;
    } catch (e) {
      print('✗ Error validasi role: $e');
      return false;
    }
  }

  /// Ambil semua data user dari Firestore
  ///
  /// [userId]: UID pengguna
  /// Returns: Future<Map<String, dynamic>?> - data user lengkap
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('✗ Error mengambil user data: $e');
      return null;
    }
  }
}
