import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_verification.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // 🔹 Register User, Verify Email, Store Data in Firestore
  void registerUser() async {
    try {
      debugPrint("Starting user registration...");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) {
        debugPrint("User is null after registration!");
        return;
      }

      debugPrint("User created successfully: ${user.uid}");

      // 🔹 Send Verification Email
      await user.sendEmailVerification();
      debugPrint("Verification email sent!");

      // 🔹 Store User Data in Firestore
      await _firestore.collection("users").doc(user.uid).set({
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "verified": false,
        "created_at": Timestamp.now(),
      }).then((_) {
        debugPrint("User data stored successfully in Firestore!");
      }).catchError((e) {
        debugPrint("Error storing user data: $e");
      });

      // 🔹 Navigate to Email Verification Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmailVerificationPage(user: user)),
      );
    } catch (e) {
      debugPrint("Registration Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  // Custom TextField builder for consistency
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
        fillColor: Colors.black.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for a powerful look
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
                // App Logo/Icon
                Icon(Icons.person_add, size: 80, color: Colors.black),
                SizedBox(height: 20),
                // Title and Subtitle
                Text("Register", style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Create a new account", style: TextStyle(color: Colors.black, fontSize: 16)),
                SizedBox(height: 30),
                // First Name Field
                _buildTextField(
                  controller: firstNameController,
                  label: "First Name",
                  icon: Icons.person,
                ),
                SizedBox(height: 15),
                // Last Name Field
                _buildTextField(
                  controller: lastNameController,
                  label: "Last Name",
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 15),
                // Email Field
                _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                ),
                SizedBox(height: 15),
                // Password Field with Eye Icon
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
                SizedBox(height: 15),
                // Confirm Password Field with Eye Icon
                _buildTextField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscureText: !isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                SizedBox(height: 25),
                // Register Button
                ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: Text('REGISTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                ),
                SizedBox(height: 20),
                // Redirect to Login Page
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/login"),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Already have an account? ", style: TextStyle(color: Colors.black, fontSize: 16)),
                        TextSpan(text: "Login", style: TextStyle(color: Colors.blue.shade900, fontSize: 16, fontWeight: FontWeight.bold)),
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
}
