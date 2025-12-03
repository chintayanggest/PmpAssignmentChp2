// lib/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '../welcome_screen.dart'; // Changed from login_screen.dart
import '../main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        // FIXED: Go to WelcomeScreen instead of LoginScreen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const WelcomeScreen()));
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFFC6FF00);
    const Color black = Color(0xFF121212);

    return Scaffold(
      backgroundColor: neonGreen,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140, height: 140,
                decoration: const BoxDecoration(color: black, shape: BoxShape.circle),
                child: const Center(
                  child: Text('\$', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: neonGreen)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('FinTrack', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: black, shadows: [Shadow(offset: Offset(2.0, 2.0), blurRadius: 3.0, color: Color.fromARGB(80, 0, 0, 0))])),
            ],
          ),
        ),
      ),
    );
  }
}