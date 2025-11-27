import 'package:explore_id/pages/plan/providers/plan_provider.dart';
import 'package:explore_id/pages/welcome.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:explore_id/provider/role_provider.dart';
import 'package:explore_id/provider/admin_provider.dart';
import 'package:explore_id/services/notificaion_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Activate App Check to ensure server accepts requests from authentic app
  // Use debug providers in non-release builds to ease local development.
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
      appleProvider:
          kReleaseMode ? AppleProvider.deviceCheck : AppleProvider.debug,
    );
  } catch (e) {
    // ignore: avoid_print
    print('AppCheck activation failed: $e');
  }
  // Log App Check token for debugging; in non-release builds token might be debug token
  try {
    final token = await FirebaseAppCheck.instance.getToken(true);
    // ignore: avoid_print
    print('AppCheck token: ${token ?? "<none>"}');
  } catch (e) {
    // ignore: avoid_print
    print('AppCheck getToken error: $e');
  }
  await NotificationService().initNotification(); // inisialisasi notifikasi

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyUserProvider()),
        ChangeNotifierProvider(create: (_) => MytripProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: "Explore ID",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white, // Warna utama
          scaffoldBackgroundColor: Colors.white, // Warna background semua page
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black, // Warna elemen utama
            secondary: Colors.blue, // Warna aksen
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            headlineMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 14),
            bodyMedium: TextStyle(fontSize: 12),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),

        home: WelcomePage(),
      ),
    );
  }
}
