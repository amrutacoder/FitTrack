import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DietHistoryPage extends StatefulWidget {
  @override
  _DietHistoryPageState createState() => _DietHistoryPageState();
}

class _DietHistoryPageState extends State<DietHistoryPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? dietData;

  // 🔹 Function to fetch diet history from Firestore
  void fetchDietHistory() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String formattedDate = selectedDate.toString().split(" ")[0]; // YYYY-MM-DD

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("diet_history")
        .doc(formattedDate)
        .get();

    if (snapshot.exists) {
      setState(() {
        dietData = snapshot.data() as Map<String, dynamic>?;
      });
    } else {
      setState(() {
        dietData = null;
      });
    }
  }

  // 🔹 Function to select a date using DatePicker
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
      appBar: AppBar(title: Text("Diet History")),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => selectDate(context),
              child: Text("Select Date"),
            ),
            SizedBox(height: 10),
            Text("Selected Date: ${selectedDate.toLocal()}".split(' ')[0]),
            SizedBox(height: 20),

            dietData != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dietData!.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  ),
                );
              }).toList(),
            )
                : Center(child: Text("No Diet Data Available")),
          ],
        ),
      ),
    );
  }
}
