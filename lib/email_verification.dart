import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'home_screen.dart'; // Replace with your actual home page import

class EmailVerificationPage extends StatefulWidget {
  final User user;

  EmailVerificationPage({required this.user});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  bool isResending = false;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkEmailVerification();
    timer = Timer.periodic(Duration(seconds: 5), (timer) => checkEmailVerification());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // 🔹 Check if email is verified
  Future<void> checkEmailVerification() async {
    await widget.user.reload();
    User? updatedUser = _auth.currentUser;
    if (updatedUser != null && updatedUser.emailVerified) {
      setState(() => isEmailVerified = true);
      timer?.cancel();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    }
  }

  // 🔹 Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      setState(() => isResending = true);
      await widget.user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification email sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a gradient background for a powerful visual effect
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon representing email verification
                Icon(Icons.email, size: 100, color: Colors.black),
                SizedBox(height: 30),
                // Title
                Text(
                  "Verify Your Email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Informative message
                Text(
                  "A verification email has been sent to \n${widget.user.email}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                // "I Have Verified" Button
                ElevatedButton(
                  onPressed: checkEmailVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: Text(
                    "I Have Verified",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                // Resend verification email link with progress indicator
                TextButton(
                  onPressed: isResending ? null : resendVerificationEmail,
                  child: isResending
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent),
                  )
                      : Text(
                    "Resend Verification Email",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
