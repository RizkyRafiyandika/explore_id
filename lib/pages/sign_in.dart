import 'package:explore_id/pages/welcome.dart';
import 'package:explore_id/services/auth_firebase.dart';
import 'package:explore_id/provider/role_provider.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:explore_id/pages/admin/admin_dashboard.dart';

class MySignIn extends StatefulWidget {
  final String?
  selectedRole; // Parameter untuk role yang dipilih dari role selection screen

  const MySignIn({super.key, this.selectedRole});

  @override
  State<MySignIn> createState() => _MySignInState();
}

class _MySignInState extends State<MySignIn> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late PageController _pageController;
  int _selectedIndex = 0;

  // Sign In Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isChecked = false;

  // Sign Up Controllers
  final _formKeySignUp = GlobalKey<FormState>();
  final TextEditingController _usernameSignUpController =
      TextEditingController();
  final TextEditingController _emailSignUpController = TextEditingController();
  final TextEditingController _passwordSignUpController =
      TextEditingController();
  final TextEditingController _confirmPasswordSignUpController =
      TextEditingController();
  bool isCheckedSignUp = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameSignUpController.dispose();
    _emailSignUpController.dispose();
    _passwordSignUpController.dispose();
    _confirmPasswordSignUpController.dispose();
    super.dispose();
  }

  void signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email dan Password tidak boleh kosong!")),
      );
      return;
    }

    User? user = await _auth.signInWithEmailAndPass(email, password);

    if (!mounted) return;

    if (user != null) {
      bool userExists = await _auth.isUserInFirestore(user.uid);

      if (userExists) {
        // Validasi role jika selectedRole ada (user memilih role di role selection screen)
        if (widget.selectedRole != null) {
          final roleProvider = context.read<RoleProvider>();
          bool isValidRole = await roleProvider.validateRoleAtLogin(
            user.uid,
            widget.selectedRole!,
          );

          if (!isValidRole) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Role Anda tidak sesuai! Anda memilih "${widget.selectedRole}" tetapi role di sistem adalah berbeda.',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            await _auth.signOut();
            return;
          }
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login berhasil!")));

        // Fetch role to determine navigation
        final roleProvider = context.read<RoleProvider>();
        await roleProvider.fetchUserRole(user.uid);
        final role = roleProvider.currentRole;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (e) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (e) => NavBar()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login gagal. Data pengguna tidak ditemukan."),
          ),
        );
        await _auth.signOut();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login gagal. Periksa kembali email & password!"),
        ),
      );
    }
  }

  void signUp() async {
    if (!_formKeySignUp.currentState!.validate()) return;
    String email = _emailSignUpController.text.trim();
    String password = _passwordSignUpController.text.trim();
    String username = _usernameSignUpController.text.trim();

    User? user = await _auth.signUpWithEmailAndPass(email, password, username);

    if (!mounted) return;

    if (user != null) {
      // Simpan role jika selectedRole ada (user memilih role di role selection screen)
      if (widget.selectedRole != null) {
        final roleProvider = context.read<RoleProvider>();
        bool success = await roleProvider.saveRoleToFirestore(
          user.uid,
          widget.selectedRole!,
        );
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Perhatian: Role tidak berhasil disimpan. ${roleProvider.errorMessage}",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Akun berhasil dibuat! Silakan login.")),
      );
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pendaftaran gagal. Coba lagi!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
            child: Image.asset('assets/pantai.jpeg', fit: BoxFit.cover),
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
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Icon(Icons.login, size: 25, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  _selectedIndex == 0
                      ? 'Sign in to NextStep'
                      : 'Sign up to NextStep',
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
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  _selectedIndex == 0
                                      ? Colors.white
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color:
                                    _selectedIndex == 0
                                        ? Colors.black
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  _selectedIndex == 1
                                      ? Colors.white
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color:
                                    _selectedIndex == 1
                                        ? Colors.black
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: [_buildSignInContent(), _buildSignUpContent()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInputField(_emailController, Icons.person, "Username"),
          _buildInputField(
            _passwordController,
            Icons.lock,
            "Password",
            obscureText: true,
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value ?? false;
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
                Flexible(
                  child: TextButton(
                    onPressed: () {},
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
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
              padding: EdgeInsets.symmetric(horizontal: 160, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text("Sign In"),
          ),
          SizedBox(height: 20),
          Text(
            "-----------------   OR Login With   -----------------",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildSocialButtons(),
          SizedBox(height: 20),
          _buildGuestLogin(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSignUpContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKeySignUp,
        child: Column(
          children: [
            _buildInputField(
              _usernameSignUpController,
              Icons.person,
              "Enter Your Username",
            ),
            _buildInputField(
              _emailSignUpController,
              Icons.email,
              "Enter Your Email",
              isEmail: true,
            ),
            _buildInputField(
              _passwordSignUpController,
              Icons.lock,
              "Enter Your Password",
              obscureText: true,
            ),
            _buildInputField(
              _confirmPasswordSignUpController,
              Icons.lock,
              "Confirm Your Password",
              obscureText: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isCheckedSignUp,
                  onChanged: (bool? value) {
                    setState(() => isCheckedSignUp = value ?? false);
                  },
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  side: BorderSide(color: Colors.white),
                ),
                Text("Remember Me", style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign Up",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "OR Sign Up With",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            SizedBox(height: 20),
            _buildSocialButtons(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 50,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(0.3),
            ),
            child: GestureDetector(
              onTap: () async {
                final user = await _auth.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (e) => NavBar()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Google Sign-In failed")),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/google.png", height: 24, width: 24),
                  SizedBox(width: 8),
                  Text(
                    "Google",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            width: 150,
            height: 50,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(0.3),
            ),
            child: GestureDetector(
              onTap: () async {
                final userCredential = await _auth.signInWithFacebook();
                if (userCredential != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (e) => NavBar()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Facebook Sign-In failed")),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/facebook.png",
                    height: 24,
                    width: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Facebook",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestLogin() {
    return GestureDetector(
      onTap: () async {
        try {
          await FirebaseAuth.instance.signInAnonymously();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavBar()),
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
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool obscureText = false,
    bool isEmail = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) return "Field cannot be empty";
          if (isEmail &&
              !RegExp(
                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$",
              ).hasMatch(value)) {
            return "Enter a valid email";
          }
          return null;
        },
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
