import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MedicationProvider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'appbar2.dart';

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  TimeOfDay? selectedTime;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String medicineName) async {
    var androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Medication Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Good Job!',
      'You have taken $medicineName',
      generalNotificationDetails,
    );
  }
  int _selectedIndex=1;
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

        break;
      case 2:
      // Navigate to Screen2
        Navigator.pushNamed(context, '/BMI');
        break;
      case 3:
      // Navigate to Screen3
        Navigator.pushNamed(context, '/BMI');
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
    final provider = Provider.of<MedicationProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name: 'Medicine Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: user != null
                    ? FirebaseFirestore.instance.collection('users').doc(user.uid).collection('medications').snapshots()
                    : null,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return _buildMedicationCard(doc, user);
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        onPressed: () => _showAddMedicationDialog(context, provider, user),
        child: Icon(Icons.add, size: 28, color: Colors.white),
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

  Widget _buildMedicationCard(DocumentSnapshot doc, User? user) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple.shade50,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Text("${doc['name']} (${doc['dose']})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Time: ${doc['time']}", style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: doc['isTaken'] ? Colors.grey : Colors.green, size: 28),
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('medications').doc(doc.id).update({'isTaken': !doc['isTaken']});
                if (!doc['isTaken']) {
                  _showNotification(doc['name']);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 28),
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('medications').doc(doc.id).delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context, MedicationProvider provider, User? user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Medication",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 15),

                // Medicine Name Input
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Medicine Name",
                    prefixIcon: Icon(Icons.medical_services, color: Colors.blue.shade900),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),

                // Dose Input
                TextFormField(
                  controller: doseController,
                  decoration: InputDecoration(
                    labelText: "Dose",
                    prefixIcon: Icon(Icons.format_list_numbered, color: Colors.blue.shade900),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 15),

                // Time Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      icon: Icon(Icons.access_time),
                      label: Text("Select Time"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    Text(
                      selectedTime != null
                          ? "${selectedTime!.format(context)}"
                          : "No Time Selected",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (selectedTime != null) {
                        final now = DateTime.now();
                        final formattedTime = DateFormat.jm().format(DateTime(
                          now.year,
                          now.month,
                          now.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        ));
                        FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('medications').add({
                          'name': nameController.text,
                          'dose': doseController.text,
                          'time': formattedTime,
                          'isTaken': false,
                        });
                        Navigator.pop(context);
                        nameController.clear();
                        doseController.clear();
                      }
                    },
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text("Add Medication"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
