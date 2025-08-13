import 'package:explore_id/pages/welcome.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/provider/userProvider.dart';
import 'package:explore_id/services/notificaion_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Tambahkan Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initNotification(); // inisialisasi notifikasi

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MyUserProvider(),
        ), // Tambahkan UserProvider
        ChangeNotifierProvider(create: (_) => MytripProvider()),
      ],
      child: MaterialApp(
        title: "Explore ID",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white, // Warna utama
          scaffoldBackgroundColor: Colors.white, // Warna background semua page
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.white, // Warna elemen utama
            secondary: Colors.blue, // Warna aksen
          ),
        ),

        home: WelcomePage(),
      ),
    );
  }
}
