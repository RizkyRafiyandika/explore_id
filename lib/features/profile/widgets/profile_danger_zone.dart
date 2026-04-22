import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:explore_id/services/auth_firebase.dart';
import 'package:explore_id/pages/sign_in.dart';

class ProfileDangerZone extends StatelessWidget {
  const ProfileDangerZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Menghapus akun bersifat permanen. Semua data Anda akan dihapus dan tidak dapat dipulihkan.",
                style: TextStyle(color: Colors.red[400], fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    showDeleteAccountDialog(context);
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Delete My Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void showDeleteAccountDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (ctx) {
        bool isLoadingLocal = false;

        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Delete Account?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content:
                  isLoadingLocal
                      ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Deleting account..."),
                        ],
                      )
                      : const Text(
                        "Apakah Anda yakin? Tindakan ini akan menghapus akun, profil, likes, komentar, dan semua aktivitas Anda secara permanen.",
                      ),
              actions:
                  isLoadingLocal
                      ? []
                      : [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            "Batal",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setStateDialog(() {
                              isLoadingLocal = true;
                            });

                            try {
                              await FirebaseAuthService().deleteUserAccount();
                              if (parentContext.mounted) {
                                Navigator.pop(ctx);
                                Navigator.pushAndRemoveUntil(
                                  parentContext,
                                  MaterialPageRoute(
                                    builder: (context) => const MySignIn(),
                                  ),
                                  (route) => false,
                                );
                                ScaffoldMessenger.of(
                                  parentContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text("Akun berhasil dihapus."),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (parentContext.mounted) {
                                setStateDialog(() {
                                  isLoadingLocal = false;
                                });
                                ScaffoldMessenger.of(
                                  parentContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll(
                                        "Exception: ",
                                        "",
                                      ),
                                    ),
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                Navigator.pop(ctx);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Ya, Hapus"),
                        ),
                      ],
            );
          },
        );
      },
    );
  }
}
