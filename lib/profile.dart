import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appbar2.dart';
import 'bottom_nav.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String firstName = "Loading...";
  String lastName = "";
  String email = "Loading...";
  String height = "Loading...";
  String weight = "Loading...";
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 🔹 Fetch User Data from Firestore
  void fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            firstName = userDoc.get("first_name") ?? "N/A";
            lastName = userDoc.get("last_name") ?? "N/A";
            email = user.email ?? "N/A";
            height = userDoc.get("height")?.toString() ?? "N/A";
            weight = userDoc.get("weight")?.toString() ?? "N/A";
          });
        } else {
          print("⚠️ No user document found!");
        }
      } catch (e) {
        print("🔥 Error fetching user data: $e");
      }
    }
  }

  // 🔹 Log Out Function
  Future<void> logout() async {
    await _auth.signOut();
    // Navigate to login page after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name: 'Profile'),
      ),
      body: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              SizedBox(height: 15),
              // 🔹 Profile Details Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileRow(Icons.person, "Name", "$firstName $lastName"),
                      _buildProfileRow(Icons.height, "Height", "$height cm"),
                      _buildProfileRow(Icons.fitness_center, "Weight", "$weight kg"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 🔹 Edit Profile Button (blue gradient)
              _buildGradientButton("Edit Profile", () {
                Navigator.pushNamed(context, '/editprofile');
              }, gradientColors: [Colors.blue.shade900, Colors.blue.shade900]),
              SizedBox(height: 20),
              // 🔹 Logout Button (red gradient)
              _buildGradientButton("Logout", () {
                logout();
              }, gradientColors: [Colors.red.shade700, Colors.red.shade700]),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Profile Row Widget
  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          SizedBox(width: 15),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
        ],
      ),
    );
  }

  // 🔹 Stylish Gradient Button Widget with customizable colors
  Widget _buildGradientButton(String text, VoidCallback onPressed, {required List<Color> gradientColors}) {
    return SizedBox(
      width: 200,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ).copyWith(
          elevation: MaterialStateProperty.all(3),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.transparent;
            },
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
