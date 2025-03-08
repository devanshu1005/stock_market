import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _firestore.collection("UserData").doc(userId).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: FutureBuilder(
        future: _fetchUserData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("User details not found"));
          }

          final userData = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("User ID: ${_auth.currentUser!.uid}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Name: ${userData['name']}", style: TextStyle(fontSize: 16)),
                Text("Phone: ${userData['phone']}", style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
