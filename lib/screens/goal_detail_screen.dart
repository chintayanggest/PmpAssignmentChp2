import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/unified_models.dart';
import '../providers/goal_provider.dart';
import '../providers/auth_provider.dart';

class GoalDetailScreen extends StatefulWidget {
  final SavingsGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _amountController = TextEditingController();

  Future<void> _addFunds() async {
    if (_amountController.text.isEmpty) return;

    // Simple parsing
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final provider = Provider.of<GoalProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    // Update logic
    final newAmount = widget.goal.currentAmount + amount;

    await provider.updateGoalProgress(widget.goal.id, newAmount, user!.id);

    if (mounted) {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Close screen to refresh (simpler than live reloading for now)
    }
  }

  void _showAddFundsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Funds'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (Rp)', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addFunds, child: const Text('Add')),
        ],
      ),
    );
  }

  Future<void> _deleteGoal() async {
    final provider = Provider.of<GoalProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    await provider.deleteGoal(widget.goal.id, user!.id);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final progress = goal.progress;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteGoal,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[900],
              child: goal.imagePath != null
                  ? Image.file(File(goal.imagePath!), fit: BoxFit.cover)
                  : const Icon(Icons.savings, size: 80, color: Color(0xFFC6FF00)),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // Progress Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC6FF00)),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard('Saved', 'Rp ${NumberFormat('#,###').format(goal.currentAmount)}'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _infoCard('Target', 'Rp ${NumberFormat('#,###').format(goal.targetAmount)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showAddFundsDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6FF00),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Add Funds', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Color(0xFFC6FF00), fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}