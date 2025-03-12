import 'dart:async';
import 'package:explore_id/pages/home.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Pindah ke halaman utama setelah 5 detik
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TweenAnimationBuilder(
          duration: Duration(seconds: 2), // Animasi selama 2 detik
          tween: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ), // Dari 0 (hilang) ke 1 (muncul)
          builder: (context, value, child) {
            return Transform.scale(
              scale: value, // Efek zoom-in
              child: Opacity(
                opacity: value, // Efek fade-in
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo fix.png', width: 200, height: 200),
                    Text(
                      'Optimal Travel,\nMaximum Experience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB433),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
