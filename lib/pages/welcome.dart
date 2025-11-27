import 'package:explore_id/pages/role_selection_screen.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _position = 0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/Bali.jpeg', fit: BoxFit.cover),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // App Title
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, 50),
              child: Text(
                'ExploreID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Main Text
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, -200),
              child: Text(
                'Optimal Travel\nMaximum Experience!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Subtext
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, -120),
              child: SizedBox(
                width: 300,
                child: Text(
                  'Seamless journeys, thrilling adventures—comfort meets excitement!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Swipe Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, -30), // Geser ke atas sedikit
              child: Stack(
                children: [
                  // Background Button
                  Container(
                    width: buttonWidth,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isCompleted ? "Welcome!" : "Swipe to Start",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  // Swipe Button
                  Positioned(
                    left: _position,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _position += details.delta.dx;
                          _position = _position.clamp(0, buttonWidth - 60);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_position > buttonWidth * 0.6) {
                          setState(() {
                            _position = buttonWidth - 60;
                            _isCompleted = true;
                          });

                          // Navigasi ke halaman berikutnya setelah geser sukses
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoleSelectionScreen(),
                              ),
                            );
                          });
                        } else {
                          setState(() {
                            _position = 0;
                          });
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.apps, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
