import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/unified_models.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // --- GOOGLE LOGIN (For Prof B) ---
  Future<String?> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return "Google Sign-In canceled";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // HYBRID SYNC: Check/Create user in SQLite
        final existingUser = await DatabaseHelper.instance.getUser(firebaseUser.email!, "GOOGLE_AUTH");

        if (existingUser != null) {
          _user = existingUser;
        } else {
          final newUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "Google User",
            email: firebaseUser.email!,
            password: "GOOGLE_AUTH", // Dummy password for SQL
            profilePath: null,
          );
          await DatabaseHelper.instance.createUser(newUser);
          _user = newUser;
        }
        return null; // Success
      }
      return "Firebase Auth Failed";
    } catch (e) {
      return "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- EXISTING FUNCTIONS (Keep these for Prof A compatibility) ---
  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        password: password,
      );
      await DatabaseHelper.instance.createUser(newUser);
      _user = newUser;
      return null;
    } catch (e) {
      return "Registration failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await DatabaseHelper.instance.getUser(email, password);
      if (user != null) {
        _user = user;
        return null;
      } else {
        return "Invalid email or password";
      }
    } catch (e) {
      return "Login error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, String? imagePath) async {
    if (_user == null) return;
    final updatedUser = _user!.copyWith(name: name, profilePath: imagePath);
    await DatabaseHelper.instance.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_user == null) return;
    await DatabaseHelper.instance.deleteUser(_user!.id);
    _user = null;
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  void logout() async {
    _user = null;
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }
}