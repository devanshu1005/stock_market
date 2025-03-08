import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  const UserDetailsScreen({required this.userId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveUserDetails() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all details")),
      );
      return;
    }

    await _firestore.collection("UserData").doc(widget.userId).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'userId': widget.userId,
    });

    // Navigate to HomeScreen after saving details
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Your Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserDetails,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
