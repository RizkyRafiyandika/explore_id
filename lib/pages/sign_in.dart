import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/sign_up.dart';
import 'package:explore_id/pages/welcome.dart';
import 'package:explore_id/services/auth_firebase.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySignIn extends StatefulWidget {
  const MySignIn({super.key});

  @override
  State<MySignIn> createState() => _MySignInState();
}

class _MySignInState extends State<MySignIn> {
  bool isChecked = false;

  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    User? user = await _auth.signInWithEmailAndPass(email, password);

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login berhasil!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (e) => NavBar()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login gagal. Periksa kembali email & password!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, //pindahin appbar ke belakang body
      appBar: AppBar(
        title: Text(
          'ExploreID',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pantai.jpeg',
              fit: BoxFit.cover,
            ), // Langsung atur opacity
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10), //jarak antar border dan icon
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(Icons.login, size: 25, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Sign in to NextStep',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MySignIn(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 30,
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text("Sign In "),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MySignUp(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                //username Textfield
                Container(
                  //border style and set padding margin
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person, color: Colors.white),
                      hintText: "Username",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //password Textfield
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ), //ketebalan garis border dan warnanya
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock, color: Colors.white),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //forgot password and remember me
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Jarak antar elemen
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value ?? false;
                                //input logic buat remmber password
                              });
                            },
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                            side: BorderSide(color: Colors.white),
                          ),
                          Text(
                            "Remember Me",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          //go to page forrgot password
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    signIn();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => NavBar()),
                      );
                    }
                    //input logic login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, //warna button
                    foregroundColor: Colors.white, //warna teks
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                    padding: EdgeInsets.symmetric(
                      horizontal: 160,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      //kenapa gk pakek decoration? decoration box hanya di pakek buat container
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Sign In"),
                ),
                SizedBox(height: 20),
                //or Sign In With---
                Text(
                  "-----------------   OR Login With   -----------------",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                //Login via Google And Facebook
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: GestureDetector(
                              //untuk menangkap gestur klik
                              onTap: () async {
                                //logic login via google
                                print("Login Google telah di tekan");
                                final user = await _auth.signInWithGoogle();
                                if (user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (e) => NavBar()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Google Sign-In failed"),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/icons/google.png",
                                      height: 24,
                                      width: 24,
                                    ),

                                    SizedBox(width: 10),
                                    Text(
                                      "Google",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: GestureDetector(
                              //untuk menangkap gestur klik
                              onTap: () {
                                //logic login via google
                                print("Login Google telah di tekan");
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/icons/facebook.png",
                                      height: 24,
                                      width: 24,
                                    ),

                                    SizedBox(width: 10),
                                    Text(
                                      "Facebook",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MySignUp(),
                              ),
                            );
                          },
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        // Vertical Divider as separator
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 20,
                          width: 1,
                          color: Colors.white54,
                        ),

                        GestureDetector(
                          onTap: () async {
                            try {
                              UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .signInAnonymously();
                              print(
                                "Login as guest: ${userCredential.user?.uid}",
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavBar(),
                                ),
                              );
                            } catch (e) {
                              print("Error login as guest: $e");
                            }
                          },
                          child: Text(
                            "Continue as Guest",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
