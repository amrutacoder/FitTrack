import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'appbar2.dart';

class DietLoggingScreen extends StatefulWidget {
  @override
  _DietLoggingScreenState createState() => _DietLoggingScreenState();
}

class _DietLoggingScreenState extends State<DietLoggingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController foodController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void logMeal() async {
    User? user = _auth.currentUser;
    if (user != null && foodController.text.isNotEmpty && caloriesController.text.isNotEmpty) {
      String userId = user.uid;
      double calories = double.tryParse(caloriesController.text) ?? 0;

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("diet_logs")
          .doc(selectedDate)
          .collection("meals")
          .add({
        "food": foodController.text,
        "calories": calories,
        "time": DateFormat('hh:mm a').format(DateTime.now())
      });

      foodController.clear();
      caloriesController.clear();
    }
  }
  int _selectedIndex = 3;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name: 'Diet Logging'),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 🌟 Food Name Input Field
              _buildStyledTextField(foodController, "Food Name", Icons.fastfood),

              SizedBox(height: 10),

              // 🌟 Calories Input Field
              _buildStyledTextField(caloriesController, "Calories", Icons.local_fire_department, isNumeric: true),

              SizedBox(height: 15),

              // 🔹 Log Meal Button (Smaller & Stylish)
              _buildGradientButton("Log Meal", logMeal),

              SizedBox(height: 15),

              // 🔹 View Diet History Button (Smaller & Stylish)
              _buildGradientButton("Diet History", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DietHistoryPage()));
              }),

              SizedBox(height: 15),

              // 🍽 Meal Log List
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: StreamBuilder(
                    stream: _firestore
                        .collection("users")
                        .doc(_auth.currentUser?.uid)
                        .collection("diet_logs")
                        .doc(selectedDate)
                        .collection("meals")
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      var meals = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          var meal = meals[index];
                          return _buildMealCard(meal["food"], meal["calories"], meal["time"]);
                        },
                      );
                    },
                  ),
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

  // 🌟 Styled TextField Function
  Widget _buildStyledTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // 🔹 Stylish Gradient Button
  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 65, // 🔹 Smaller Button
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
              colors: [Colors.blue.shade900, Colors.blue.shade900],
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

  // 🍽 Meal Log Card Function
  Widget _buildMealCard(String food, double calories, String time) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.restaurant, color: Colors.blue.shade900),
        title: Text(food, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("$calories kcal | $time", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ),
    );
  }
}


class DietHistoryPage extends StatefulWidget {
  @override
  _DietHistoryPageState createState() => _DietHistoryPageState();
}

class _DietHistoryPageState extends State<DietHistoryPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> meals = [];
  int _selectedIndex = 4;

  // 🔹 Fetch diet history from Firestore
  void fetchDietHistory() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("diet_logs")
        .doc(formattedDate)
        .collection("meals")
        .get();

    setState(() {
      meals = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // 🔹 Show Date Picker
  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchDietHistory();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDietHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name: 'Diet History'),
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
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌟 Date Picker Button (Stylish)
              _buildGradientButton("Select Date", () => selectDate(context)),

              SizedBox(height: 10),

              // 📅 Selected Date Text
              Text(
                "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),

              // 🍽 Diet History List
              meals.isNotEmpty
                  ? Flexible(
                child: ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    var meal = meals[index];
                    return _buildMealCard(meal["food"], meal["calories"], meal["time"]);
                  },
                ),
              )
                  : Expanded(
                child: Center(
                  child: Text(
                    "No Diet Data Available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Stylish Gradient Button
  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 65, // 🔹 Smaller Button
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
              colors: [Colors.blue.shade900, Colors.blue.shade900],
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

  // 🍽 Meal Log Card Function
  Widget _buildMealCard(String food, double calories, String time) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.restaurant, color: Colors.blue.shade900),
        title: Text(food, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("$calories kcal | $time", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ),
    );
  }
}
