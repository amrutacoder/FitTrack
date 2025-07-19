import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;

  // 🔹 Sign in with Email and Password
  Future<void> login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email before logging in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // 🔹 Reset Password
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter your email first!')),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to email!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // 🔹 Sign in with Google
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed in with Google!')),
    );
    Navigator.pushReplacementNamed(context, "/relax");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a gradient background for a powerful look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 App Logo or Icon
                Icon(Icons.lock, size: 80, color: Colors.black),
                SizedBox(height: 20),
                // 🔹 Title and Subtitle
                Text("Welcome Back!", style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Sign in to continue", style: TextStyle(color: Colors.black, fontSize: 16)),
                SizedBox(height: 30),

                // 🔹 Email Field
                _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                ),
                SizedBox(height: 20),

                // 🔹 Password Field with Visibility Toggle
                _buildTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  obscureText: !isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),

                // 🔹 Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: Text("Forgot Password?", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(height: 20),

                // 🔹 Login Button
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                ),
                SizedBox(height: 25),

                // 🔹 Divider with OR
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.black , thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.black)),
                    ),
                    Expanded(child: Divider(color: Colors.black, thickness: 1)),
                  ],
                ),
                SizedBox(height: 25),

                // 🔹 Social Media Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google
                    _buildSocialIcon(
                      onTap: signInWithGoogle,
                      icon: FontAwesomeIcons.google,
                      backgroundColor: Colors.red[400],
                    ),
                    SizedBox(width: 20),
                    // Facebook
                    _buildSocialIcon(
                      onTap: () {}, // Implement Facebook Login
                      icon: FontAwesomeIcons.facebookF,
                      backgroundColor: Colors.blue[600],
                    ),
                    SizedBox(width: 20),
                    // GitHub
                    _buildSocialIcon(
                      onTap: () {}, // Implement GitHub Login
                      icon: FontAwesomeIcons.github,
                      backgroundColor: Colors.black,
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // 🔹 Sign-up Redirect
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/signup"),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Don't have an account? ", style: TextStyle(color: Colors.black, fontSize: 16)),
                        TextSpan(text: "Sign up", style: TextStyle(color: Colors.blue.shade900, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom TextField builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Custom Social Icon builder
  Widget _buildSocialIcon({
    required VoidCallback onTap,
    required IconData icon,
    required Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: backgroundColor,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
