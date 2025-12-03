// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color neonGreen = Color(0xFFC6FF00);
    const Color black = Color(0xFF121212);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Welcome Back!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Log in to your account', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 48),

            // Email
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Email', labelStyle: const TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: neonGreen))),
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Password', labelStyle: const TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: neonGreen))),
            ),
            const SizedBox(height: 32),

            // Normal Login
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: neonGreen, foregroundColor: black, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: authProvider.isLoading ? null : () async {
                final error = await authProvider.login(_emailController.text, _passwordController.text);
                if (error == null && mounted) {
                  await Provider.of<TransactionProvider>(context, listen: false).fetchData(authProvider.user!.id);
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainScreen()), (route) => false);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error')));
                }
              },
              child: authProvider.isLoading ? const CircularProgressIndicator() : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 16),

            // --- NEW: GOOGLE BUTTON ---
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: authProvider.isLoading ? null : () async {
                final error = await authProvider.loginWithGoogle();

                if (error == null && mounted) {
                  // Success!
                  await Provider.of<TransactionProvider>(context, listen: false).fetchData(authProvider.user!.id);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false
                  );
                } else if (mounted) {
                  // Error
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Login Failed')));
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata, size: 28, color: Colors.red), // Or use an image asset if you prefer
                  SizedBox(width: 8),
                  Text('Sign in with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),


            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              child: const Text(
                "Don't have an account? Register",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}