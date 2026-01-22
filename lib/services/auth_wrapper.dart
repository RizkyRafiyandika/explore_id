import 'package:explore_id/pages/admin/admin_dashboard.dart';
import 'package:explore_id/pages/welcome.dart';
import 'package:explore_id/provider/role_provider.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// AuthWrapper - Widget untuk mengecek status authentication saat app dibuka
///
/// Widget ini akan:
/// - Listen ke Firebase Auth state changes
/// - Jika user sudah login → fetch role → navigate ke NavBar (user) atau AdminDashboard (admin)
/// - Jika user belum login → navigate ke WelcomePage
/// - Menampilkan loading indicator saat checking auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state - menunggu auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User sudah login
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: _getUserRole(context, user.uid),
            builder: (context, roleSnapshot) {
              // Loading role
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Navigate berdasarkan role
              final role = roleSnapshot.data;
              if (role == 'admin') {
                return const AdminDashboard();
              } else {
                // Default ke NavBar untuk user biasa atau guest
                return const NavBar();
              }
            },
          );
        }

        // User belum login - tampilkan WelcomePage
        return const WelcomePage();
      },
    );
  }

  /// Fetch user role dari Firestore
  Future<String?> _getUserRole(BuildContext context, String uid) async {
    try {
      final roleProvider = context.read<RoleProvider>();
      await roleProvider.fetchUserRole(uid);
      return roleProvider.currentRole;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }
}
