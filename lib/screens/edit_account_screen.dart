// lib/screens/edit_account_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unified_models.dart'; // EXCLUSIVE IMPORT
// REMOVED: import '../models/account.dart';
import '../providers/transaction_provider.dart';

class EditAccountScreen extends StatefulWidget {
  final Account account;

  const EditAccountScreen({super.key, required this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _balanceController = TextEditingController(text: widget.account.balance.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newName = _nameController.text;
    final newBalance = double.tryParse(_balanceController.text) ?? widget.account.balance;

    if (newName.isEmpty) { return; }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: const Text('Are you sure you want to save these changes?'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false).updateAccount(
                id: widget.account.id,
                newName: newName,
                newBalance: newBalance,
              );
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account updated successfully!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.account.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current Balance', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Cancel')),
                ElevatedButton(onPressed: _saveChanges, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Save')),
              ],
            )
          ],
        ),
      ),
    );
  }
}