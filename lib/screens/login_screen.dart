// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'main_screen.dart'; // The main dashboard

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFFC6FF00);
    const Color black = Color(0xFF121212);

    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log in to your account',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // Email Field
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: neonGreen)),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: neonGreen)),
              ),
            ),
            const SizedBox(height: 32),

            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: neonGreen,
                foregroundColor: black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // For now, just navigate to the main screen
                // We use pushAndRemoveUntil to clear the login screens from the back stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                      (Route<dynamic> route) => false, // This predicate removes all previous routes
                );
              },
              child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}