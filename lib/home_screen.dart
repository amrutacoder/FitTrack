import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'bottom_nav.dart';
import 'appbar1.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = "";
  String firstName = "";
  late VideoPlayerController _videoController;
  String dailyMessage = "";
  double calories = 0;
  String nextmedicine='';
  double waterIntake = 0;
  double bmi = 0;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    // For example:
    switch (index) {
      case 0:
      // Home Screen already loaded
        break;
      case 1:
      // Navigate to Screen1
        Navigator.pushNamed(context, '/MRS');
        break;
      case 2:
      // Navigate to Screen2
        Navigator.pushNamed(context, '/BMI');
        break;
      case 3:
      // Navigate to Screen3
        Navigator.pushNamed(context, '/Diet');
        break;
      case 4:
      // Navigate to Screen4
        Navigator.pushNamed(context, '/water_intake');
        break;
      case 5:
      // Navigate to Screen4
        Navigator.pushNamed(context, '/relax');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;

    // If user is null, then no one is logged in
    if (user == null) {
      LoginPage();
    } else {
      HomeScreen();
    }

    userId = auth.currentUser?.uid ?? "";
    fetchUserName();
    fetchUserData();

    _videoController = VideoPlayerController.asset("assets/images/video.mp4")
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });

    calories = 0.0;
    fetchDailyMessage();
    fetchUserData();
  }

  Future<void> fetchUserName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      firstName = userDoc.exists ? userDoc['first_name'] ?? "User" : "User";
    });
  }

  Future<void> fetchUserData() async {
    // Fetch height and weight
    double height = 0.0;
    double weight = 0.0;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      print(userDoc.data().toString());
      height = ((userDoc['height'] ?? 0) as num).toDouble() / 100; // Convert cm to meters
      weight = ((userDoc['weight'] ?? 0) as num).toDouble();
      if (height > 0 && weight > 0) {
        setState(() {
          bmi = weight / (height * height);
        });
      }
    }

    // Fetch calories from diet logs
    double totalCalories = 0;
    QuerySnapshot dietSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('diet_logs').doc(currentDate) // Corrected path
        .collection('meals')
        .get();
    print(dietSnapshot.toString());
    for (var doc in dietSnapshot.docs) {
      totalCalories += (doc['calories'] ?? 0).toDouble();
    }
    setState(() {
      calories = totalCalories;
    });

    // Fetch water intake from logs
    double totalWater = 0.0;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection(currentDate)
        .doc("water_intake")
        .collection("logs")
        .get();

    for (var doc in snapshot.docs) {
      totalWater += (doc['amount'] ?? 0).toDouble();
    }

    setState(() {
      waterIntake = totalWater;
    });


    DateTime now = DateTime.now();

    QuerySnapshot snapshot1 = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("medications")
        .get();

    String? nextMedicineName;
    DateTime? nextMedicineTime;

    for (var doc in snapshot1.docs) {
      String medTime = doc['time']; // Medication time in 12-hour format like "11:17 AM"
      DateTime medDateTime = DateFormat.jm().parse(medTime);

      // Attach today's date for accurate comparison
      medDateTime = DateTime(now.year, now.month, now.day, medDateTime.hour, medDateTime.minute);

      if (medDateTime.isAfter(now)) {
        if (nextMedicineTime == null || medDateTime.isBefore(nextMedicineTime)) {
          nextMedicineName = doc['name'];
          nextMedicineTime = medDateTime;
        }
      }
    }

    setState(() {
      nextmedicine = nextMedicineName ?? "N/A";
    });


  }

  Future<void> fetchDailyMessage() async {
    DocumentSnapshot messageDoc = await FirebaseFirestore.instance.collection('dailyMessages').doc('message').get();
    setState(() {
      dailyMessage = messageDoc.exists ? messageDoc['text'] ?? "Stay healthy and positive!" : "Stay healthy and positive!";
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar(title: "Welcome", userName: firstName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $currentDate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Colors.blue.shade900)),
            SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _progressCard("Calories", "$calories kcal", "assets/images/cal.jpg"),
                    _progressCard("Water", "$waterIntake ml", "assets/images/water.jpeg"),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _progressCard("BMI", "${bmi.toStringAsFixed(1)}", "assets/images/BMI.jpg"),
                    _progressCard("Next Medicine", nextmedicine, "assets/images/medicine.jpg"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: _videoController.value.isInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              )
                  : CircularProgressIndicator(),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(dailyMessage,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.blue.shade900),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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

  Widget _progressCard(String title, String value, String image) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(image, height: 80, width: 80, fit: BoxFit.cover),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
