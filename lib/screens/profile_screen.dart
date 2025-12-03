// lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // IMPORT THIS
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

// -----------------------------------------------------------------------------
// 1. EDIT PROFILE SCREEN
// -----------------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _imagePath = user.profilePath;
    }
  }

  Future<void> _pickImage() async {
    // --- PERMISSION LOGIC ---
    if (Platform.isAndroid) {
      // Request Photos (Android 13+)
      await Permission.photos.request();
      // Request Storage (Android 12 and below)
      await Permission.storage.request();
    }
    // ------------------------

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  void _save() {
    if (_nameController.text.isEmpty) return;
    Provider.of<AuthProvider>(context, listen: false).updateProfile(_nameController.text, _imagePath);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 12),
              const Text("Tap to change photo", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. HELP & SUPPORT SCREEN
// -----------------------------------------------------------------------------
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(title: Text("How do I add a transaction?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Go to the Dashboard and click the '+' button at the bottom right corner."))]),
          ExpansionTile(title: Text("Can I edit my budget goals?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Yes, go to the Goals tab, click on a goal, and select edit."))]),
          ExpansionTile(title: Text("Is my data safe?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Yes, all data is stored locally on your device in a secure database."))]),
          ExpansionTile(title: Text("How do I contact support?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Email us at support@fintrack.com"))]),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. SETTINGS SCREEN (Delete Account)
// -----------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(leading: Icon(Icons.language), title: Text("Language"), trailing: Text("English")),
          const Divider(),
          const ListTile(leading: Icon(Icons.notifications), title: Text("Notifications"), trailing: Icon(Icons.toggle_on, color: Colors.blue)),
          const Divider(),
          const ListTile(leading: Icon(Icons.currency_exchange), title: Text("Currency"), trailing: Text("IDR (Rp)")),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Account?"),
                  content: const Text("This will permanently erase all your data. This action cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Provider.of<AuthProvider>(context, listen: false).deleteAccount();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. MAIN PROFILE SCREEN
// -----------------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final name = user?.name ?? "User";
    final email = user?.email ?? "";
    final profilePath = user?.profilePath;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB), // Light grey background
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 32),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: profilePath != null ? FileImage(File(profilePath)) : null,
                  child: profilePath == null ? const Icon(Icons.person, size: 60, color: Colors.blueAccent) : null,
                ),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuItem(context, icon: Icons.edit, title: "Edit Profile", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                }),
                const SizedBox(height: 16),
                _buildMenuItem(context, icon: Icons.currency_exchange, title: "Currency: IDR", onTap: () {}),
                const SizedBox(height: 16),
                _buildMenuItem(context, icon: Icons.settings, title: "Settings", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                }),
                const SizedBox(height: 16),
                _buildMenuItem(context, icon: Icons.help_outline, title: "Help & Support", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                }),
                const SizedBox(height: 16),
                _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: "Logout",
                    color: Colors.redAccent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () {
                                authProvider.logout();
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                              },
                              child: const Text("Logout", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color color = Colors.black87}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color == Colors.black87 ? Colors.blueAccent : color),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color))),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}