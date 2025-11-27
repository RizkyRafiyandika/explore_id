import 'package:flutter/material.dart';
import 'package:explore_id/services/role_service.dart';

/// Provider untuk mengelola state role pengguna
class RoleProvider with ChangeNotifier {
  final RoleService _roleService = RoleService();

  String? _currentRole;
  bool _isLoading = false;
  String? _errorMessage;

  // Getter untuk mendapatkan role saat ini
  String? get currentRole => _currentRole;

  // Getter untuk status loading
  bool get isLoading => _isLoading;

  // Getter untuk error message
  String? get errorMessage => _errorMessage;

  /// Mengatur role pengguna saat ini (sebelum login/signup)
  ///
  /// [role]: "user" atau "admin"
  void setSelectedRole(String role) {
    _currentRole = role;
    notifyListeners();
    print('✓ Role dipilih: $role');
  }

  /// Fetch role dari Firestore dan set ke provider
  ///
  /// [userId]: UID pengguna dari Firebase Auth
  Future<void> fetchUserRole(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? role = await _roleService.getUserRole(userId);
      _currentRole = role;
      print('✓ Role diambil dari Firestore: $role');
    } catch (e) {
      _errorMessage = e.toString();
      print('✗ Error fetch role: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Simpan role ke Firestore (setelah signup)
  ///
  /// [userId]: UID pengguna dari Firebase Auth
  /// [role]: "user" atau "admin"
  /// Returns: Future<bool> - true jika berhasil
  Future<bool> saveRoleToFirestore(String userId, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _roleService.saveUserRole(userId, role);
      _currentRole = role;
      print('✓ Role disimpan ke Firestore: $role');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan role: $e';
      print('✗ Error save role: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validasi role untuk login
  ///
  /// [userId]: UID pengguna
  /// [expectedRole]: role yang diharapkan
  /// Returns: Future<bool> - true jika valid
  Future<bool> validateRoleAtLogin(String userId, String expectedRole) async {
    try {
      bool isValid = await _roleService.validateUserRole(userId, expectedRole);
      if (!isValid) {
        _errorMessage =
            'Role Anda tidak sesuai dengan role yang dipilih saat login';
      }
      return isValid;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Cek apakah user adalah admin
  ///
  /// Returns: bool
  bool isAdmin() => _currentRole == 'admin';

  /// Cek apakah user adalah regular user
  ///
  /// Returns: bool
  bool isRegularUser() => _currentRole == 'user';

  /// Clear role dan error (untuk logout)
  void clearRole() {
    _currentRole = null;
    _errorMessage = null;
    notifyListeners();
    print('✓ Role telah dihapus');
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
