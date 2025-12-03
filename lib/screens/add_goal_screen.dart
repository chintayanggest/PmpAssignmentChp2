import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/unified_models.dart';
import '../providers/goal_provider.dart';
import '../providers/auth_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();

  DateTime? _selectedDate;
  String? _imagePath;
  bool _isLoading = false;

  // Colors from your design
  final Color _bgBlack = const Color(0xFF121212);
  final Color _neonGreen = const Color(0xFFC6FF00);
  final Color _inputGrey = const Color(0xFF1E1E1E);
  final Color _hintGrey = const Color(0xFF757575);

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (Platform.isAndroid) {
      await Permission.photos.request();
      await Permission.storage.request();
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _neonGreen,
              onPrimary: Colors.black,
              surface: _bgBlack,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      // Clean amount string
      final cleanAmount = _targetAmountController.text.replaceAll('.', '').replaceAll(',', '');
      final targetAmount = double.parse(cleanAmount);

      final goal = SavingsGoal(
        id: const Uuid().v4(),
        userId: user.id,
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: 0.0,
        targetDate: _selectedDate,
        imagePath: _imagePath,
      );

      await Provider.of<GoalProvider>(context, listen: false).addGoal(goal);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBlack,
      appBar: AppBar(
        title: const Text('Create New Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _bgBlack,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGE PICKER
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _inputGrey,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _neonGreen, width: 1.5),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 12),
                      const Text('Add Goal Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Visualize your dream', style: TextStyle(color: _hintGrey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. GOAL NAME
              _buildLabel('Goal Name'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'e.g., Norway Trip, New MacBook',
                  icon: Icons.flag,
                ),
                validator: (val) => val!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 20),

              // 3. TARGET AMOUNT
              _buildLabel('Target Amount'),
              TextFormField(
                controller: _targetAmountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  hint: '0',
                  prefixText: 'Rp  ',
                ),
                validator: (val) => val!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 20),

              // 4. DATE PICKER
              _buildLabel('Target Date (Optional)'),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: _inputGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: _selectedDate != null ? _neonGreen : _hintGrey),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select target date'
                            : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null ? _hintGrey : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 5. CREATE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _neonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Create Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper for Input Decoration
  InputDecoration _inputDecoration({String? hint, IconData? icon, String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _hintGrey, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: _hintGrey) : null,
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      filled: true,
      fillColor: _inputGrey,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _neonGreen),
      ),
    );
  }
}