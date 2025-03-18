import 'package:explore_id/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:provider/provider.dart'; // Tambahkan Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      ],
      child: MaterialApp(
        title: "Explore ID",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blueGrey),
        home: NavBar(),
      ),
    );
  }
}
