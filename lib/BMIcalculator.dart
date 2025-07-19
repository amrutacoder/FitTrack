import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appbar2.dart';
import 'bottom_nav.dart';

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = "";
  double height = 0.0;
  double weight = 0.0;
  double bmi = 0.0;
  String category = "";
  String healthTip = "";

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      fetchUserData();
    }
  }

  void fetchUserData() async {
    // Fetch user data using the proper userId
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      print(userDoc.data().toString());
      setState(() {
        height = ((userDoc['height'] ?? 0) as num).toDouble() / 100; // Convert cm to meters
        weight = ((userDoc['weight'] ?? 0) as num).toDouble();
        if (height > 0 && weight > 0) {
          bmi = weight / (height * height);
          determineBMICategory();
        }
      });
    }
  }

  void determineBMICategory() {
    if (bmi < 18.5) {
      category = "Underweight";
      healthTip = "Increase calorie intake with healthy foods.";
    } else if (bmi < 24.9) {
      category = "Normal";
      healthTip = "Maintain your balanced diet and exercise.";
    } else if (bmi < 29.9) {
      category = "Overweight";
      healthTip = "Incorporate more exercise and mindful eating.";
    } else {
      category = "Obese";
      healthTip = "Consult a doctor for a structured weight management plan.";
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/MRS');
        break;
      case 2:
      // Already on BMI screen
        break;
      case 3:
        Navigator.pushNamed(context, '/Diet');
        break;
      case 4:
        Navigator.pushNamed(context, '/water_intake');
        break;
      case 5:
        Navigator.pushNamed(context, '/relax');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name: 'BMI Calculator'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: bmi / 40,
                      backgroundColor: Colors.grey[300],
                      strokeWidth: 12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        bmi < 18.5
                            ? Colors.blue
                            : bmi < 24.9
                            ? Colors.green
                            : bmi < 29.9
                            ? Colors.black
                            : Colors.red,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 40),
                      SizedBox(height: 10),
                      Text(bmi.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(category,
                          style: TextStyle(
                              fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Health Tip",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 5),
                    Text(healthTip,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'BMI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'WaterIntake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'RelaxSession',
          ),
        ],
      ),
    );
  }
}
