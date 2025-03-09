import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_market/screens/home_screen.dart';
import 'package:stock_market/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Tracks auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loader
        }
        if (snapshot.hasData) {
          return HomeScreen(); // User is logged in
        }
        return LoginScreen(); // User is logged out
      },
    );
  }
}