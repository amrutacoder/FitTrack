import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appbar2.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 🔹 Fetch User Data and Pre-fill Fields
  void fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          firstNameController.text = userDoc.get("first_name") ?? "";
          lastNameController.text = userDoc.get("last_name") ?? "";
          heightController.text = userDoc.get("height")?.toString() ?? "";
          weightController.text = userDoc.get("weight")?.toString() ?? "";
        });
      }
    }
  }

  // 🔹 Save Updated Data
  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).update({
          "first_name": firstNameController.text.trim(),
          "last_name": lastNameController.text.trim(),
          "height": int.tryParse(heightController.text.trim()) ?? 0,
          "weight": int.tryParse(weightController.text.trim()) ?? 0,
        });

        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile Updated Successfully!")),
        );

        Navigator.pop(context); // 🔹 Go back to Profile Page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomAppBar1(title: "Welcome", name:'Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Height (cm)", heightController, isNumber: true),
              _buildTextField("Weight (kg)", weightController, isNumber: true),
              SizedBox(height: 30),

              // 🔹 Save Button
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Input Field
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return "This field can't be empty";
          return null;
        },
      ),
    );
  }

  // 🔹 Stylish Save Button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: saveProfile,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.blue.shade900
        ),
        child: Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
      ),
    );
  }
}
