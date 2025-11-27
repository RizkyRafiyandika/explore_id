import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/sign_in.dart';

/// Halaman pemilihan role (User atau Admin)
///
/// Menampilkan 2 kartu dengan animasi smooth untuk memilih role
/// Setelah pemilihan, navigasi ke sign_in dengan role yang dipilih
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedRole;
  late AnimationController _userCardController;
  late AnimationController _adminCardController;

  @override
  void initState() {
    super.initState();
    _userCardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _adminCardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _userCardController.dispose();
    _adminCardController.dispose();
    super.dispose();
  }

  /// Handle pemilihan role
  ///
  /// [role]: role yang dipilih ("user" atau "admin")
  void _onRoleTapped(String role) {
    setState(() {
      _selectedRole = role;
    });

    // Trigger animasi
    if (role == 'user') {
      _userCardController.forward().then((_) {
        _showConfirmationDialog(role);
      });
    } else {
      _adminCardController.forward().then((_) {
        _showConfirmationDialog(role);
      });
    }
  }

  /// Tampilkan dialog konfirmasi sebelum navigasi
  ///
  /// [role]: role yang dipilih
  void _showConfirmationDialog(String role) {
    String roleName = role == 'user' ? 'Pengguna Biasa' : 'Administrator';
    String roleDesc =
        role == 'user'
            ? 'Anda akan mendaftar/login sebagai pengguna biasa yang dapat menjelajahi destinasi wisata'
            : 'Anda akan mendaftar/login sebagai administrator dengan akses kontrol penuh';

    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Konfirmasi Pilihan Role',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tblack,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tdcyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        role == 'user'
                            ? Icons.person
                            : Icons.admin_panel_settings,
                        color: tdcyan,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Role: $roleName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: tdcyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Reset animasi
                  _userCardController.reverse();
                  _adminCardController.reverse();
                },
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tdcyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigasi ke sign_in dengan passing selected role
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MySignIn(selectedRole: role),
                    ),
                  );
                },
                child: const Text(
                  'Lanjutkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Build kartu role
  Widget _buildRoleCard(
    String role,
    IconData icon,
    String title,
    String description,
    AnimationController controller,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      child: GestureDetector(
        onTap: () => _onRoleTapped(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _selectedRole == role ? tdcyan : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _selectedRole == role ? tdcyan : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _selectedRole == role
                        ? tdcyan.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color:
                        _selectedRole == role
                            ? Colors.white.withOpacity(0.2)
                            : tdcyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: _selectedRole == role ? Colors.white : tdcyan,
                  ),
                ),
                const SizedBox(height: 15),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _selectedRole == role ? Colors.white : tblack,
                  ),
                ),
                const SizedBox(height: 10),
                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _selectedRole == role
                            ? Colors.white.withOpacity(0.85)
                            : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                // Check icon jika dipilih
                if (_selectedRole == role)
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Pilih Role',
          style: TextStyle(
            color: tblack,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tblack, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tdcyanwhite.withOpacity(0.3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Text(
                  'Selamat datang di ExploreID',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: tblack,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pilih role Anda untuk melanjutkan',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 50),
                // Role cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 25,
                    children: [
                      // User card
                      _buildRoleCard(
                        'user',
                        Icons.person,
                        'Pengguna Biasa',
                        'Jelajahi destinasi wisata,\nlihat rekomendasi, dan\nbuat rencana perjalanan',
                        _userCardController,
                      ),
                      // Admin card
                      _buildRoleCard(
                        'admin',
                        Icons.admin_panel_settings,
                        'Administrator',
                        'Kelola konten, moderasi,\ndan pantau aktivitas\npengguna di platform',
                        _adminCardController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Helper text
                Text(
                  'Anda bisa mengubah role di pengaturan akun nanti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
