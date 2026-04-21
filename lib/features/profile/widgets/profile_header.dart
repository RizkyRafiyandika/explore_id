import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/setting.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:explore_id/features/profile/providers/user_provider.dart';

class ProfileHeader extends StatelessWidget {
  final MyUserProvider userProvider;
  final User? user;

  const ProfileHeader({
    super.key,
    required this.userProvider,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final displayUsername =
        (user == null || user!.isAnonymous) ? "Guest" : userProvider.username;

    final displayEmail =
        (user == null || user!.isAnonymous) ? "No email" : userProvider.email;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: tdcyan,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              // Settings button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (e) => MySettingPage()),
                      );
                    },
                  ),
                ),
              ),
              // Profile Picture Stacked half-way
              Positioned(
                bottom: -50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Consumer<MyUserProvider>(
                        builder: (context, provider, child) {
                          ImageProvider backgroundImage;
                          if (provider.profileImageUrl != null &&
                              provider.profileImageUrl!.isNotEmpty) {
                            backgroundImage = NetworkImage(
                              provider.profileImageUrl!,
                            );
                          } else if (provider.imageFile != null) {
                            backgroundImage = FileImage(provider.imageFile!);
                          } else {
                            backgroundImage = const AssetImage(
                              'assets/profile_pic.jpg',
                            );
                          }
                          return CircleAvatar(
                            backgroundImage: backgroundImage,
                            radius: 50,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          final provider = Provider.of<MyUserProvider>(
                            context,
                            listen: false,
                          );
                          _showImageBar(context, provider);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: tdcyan,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Text(
            displayUsername,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: displayEmail));
              customToast("Email copied to clipboard");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tdcyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tdcyan.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: tdcyan,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.copy_rounded,
                    color: tdcyan.withValues(alpha: 0.8),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showImageBar(BuildContext context, MyUserProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Change Profile Photo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        context,
                        Icons.camera_alt_rounded,
                        'Camera',
                        Colors.blue,
                        () async {
                          await provider.uploadImageCamera();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageOption(
                        context,
                        Icons.photo_library_rounded,
                        'Gallery',
                        Colors.green,
                        () async {
                          await provider.pickImageGalery();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the existing WaveClipperUp class as is
class WaveClipperUp extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 50,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
