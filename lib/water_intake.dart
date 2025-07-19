import 'package:alera/appbar2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'bottom_nav.dart';

class WaterIntakeScreen extends StatefulWidget {
  @override
  _WaterIntakeScreenState createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double waterGoal = 2000;
  double currentIntake = 0;
  double selectedAmount = 250;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    fetchTotalWaterIntake();
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    // For example:
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
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

        break;
      case 5:
      // Navigate to Screen4
        Navigator.pushNamed(context, '/relax');
        break;
    }
  }

  void logWater(double amount) async {
    setState(() {
      currentIntake += amount;
      _animationController.forward(from: 0);
    });

    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String timestamp = DateFormat('hh:mm a').format(DateTime.now());

      await _firestore
          .collection("users")
          .doc(userId)
          .collection(today)
          .doc("water_intake")
          .collection("logs")
          .add({
        "amount": amount,
        "time": timestamp,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name: 'WaterIntake'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: (currentIntake / waterGoal).clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade900),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${((currentIntake / waterGoal) * 100).toStringAsFixed(
                            1)}%",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${currentIntake.toInt()} / ${waterGoal.toInt()} mL",
                        style: TextStyle(fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWaterButton(50, FontAwesomeIcons.tint),
                  _buildWaterButton(150, FontAwesomeIcons.tint),
                ],
              ),
              SizedBox(height: 20),
              Text("Select Amount: ${selectedAmount.toInt()} ml",
                  style: TextStyle(color: Colors.blue.shade900, fontSize: 16)),
              Slider(
                min: 100,
                max: 1000,
                divisions: 9,
                activeColor: Colors.blue.shade900,
                inactiveColor: Colors.grey[700],
                value: selectedAmount,
                onChanged: (value) {
                  setState(() {
                    selectedAmount = value;
                  });
                },
              ),
              SizedBox(height: 10),
              _buildWaterButton(selectedAmount, FontAwesomeIcons.tint),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WaterHistoryScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text("View History", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ), bottomNavigationBar: BottomNavigationBar(
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

  Widget _buildWaterButton(double amount, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => logWater(amount),
      icon: Icon(icon, color: Colors.white),
      label: Text("+${amount.toInt()}ml", style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }

  void fetchTotalWaterIntake() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection(today)
          .doc("water_intake")
          .collection("logs")
          .get();

      double totalWater = 0.0;
      for (var doc in snapshot.docs) {
        totalWater += (doc['amount'] ?? 0).toDouble();
      }

      setState(() {
        currentIntake = totalWater;
        _animationController.forward(from: 0);
      });
    }
  }
}

class WaterHistoryScreen extends StatefulWidget {
  @override
  _WaterHistoryScreenState createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends State<WaterHistoryScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  double totalIntake = 0;
  double waterGoal = 2000;
  List<Map<String, dynamic>> _waterLogs = [];

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    fetchWaterIntake();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void fetchWaterIntake() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      double total = 0;
      List<Map<String, dynamic>> logs = [];

      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection(selectedDate)
          .doc("water_intake")
          .collection("logs")
          .get();

      for (var doc in snapshot.docs) {
        total += doc["amount"];
        logs.add({
          "amount": doc["amount"],
          "time": formatTime(doc["time"]),
        });
      }

      setState(() {
        totalIntake = total.clamp(0, waterGoal); // Ensure value stays within range
        _waterLogs = logs;
        _animationController.forward(from: 0); // Restart animation
      });
    }
  }


  // Convert time from "16:53:37" to "4:53 PM"
  String formatTime(String time24) {
    try {
      DateTime time = DateFormat("HH:mm:ss").parse(time24);
      return DateFormat("h:mm a").format(time);
    } catch (e) {
      return time24; // Fallback in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dark theme
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome",name:' WaterIntake History'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            // Date Picker
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark(),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                  fetchWaterIntake();
                }
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      selectedDate,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Animated Progress Indicator
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                double progress = (totalIntake / waterGoal).clamp(0.0, 1.0);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value * progress,
                        backgroundColor: Colors.white12,
                        strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${(progress * 100).toStringAsFixed(1)}%",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "${totalIntake.toInt()} / ${waterGoal.toInt()} mL",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),


            SizedBox(height: 30),

            // Water Intake Logs (Grid Layout: Two per Row)
            Expanded(
              child: _waterLogs.isEmpty
                  ? Center(child: Text("No logs available", style: TextStyle(color: Colors.white54)))
                  : GridView.builder(
                itemCount: _waterLogs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two logs per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  var log = _waterLogs[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(Icons.local_drink, color: Colors.blue.shade900),
                      title: Text("${log['amount']} mL", style: TextStyle(color: Colors.black)),
                      subtitle: Text("${log['time']}", style: TextStyle(color: Colors.black)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
