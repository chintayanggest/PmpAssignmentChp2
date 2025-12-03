// lib/screens/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/unified_models.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'dart:io';
import 'fullscreen_image_viewer.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction; // This is used mainly for the ID now

  const TransactionDetailScreen({super.key, required this.transaction});

  void _deleteTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Do you want to permanently delete this transaction?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () { Navigator.of(ctx).pop(); },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(transaction.id);
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the original transaction, AddTransactionScreen handles the logic
        builder: (context) => AddTransactionScreen(transactionToEdit: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WRAP IN CONSUMER to listen for updates
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Find the LATEST version of this transaction from the provider
        // If it was deleted, we return a fallback (or handle it, though pop usually happens first)
        TransactionModel currentTransaction;
        try {
          currentTransaction = provider.transactions.firstWhere((t) => t.id == transaction.id);
        } catch (e) {
          // If transaction is not found (e.g. just deleted), return empty or loading
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(currentTransaction.date);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction Detail'),
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _editTransaction(context)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTransaction(context)),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        currentTransaction.category.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp${currentTransaction.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: currentTransaction.type == TransactionType.expense ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildDetailRow('Account', currentTransaction.account.name, icon: currentTransaction.account.icon),
                const Divider(),
                _buildDetailRow('Category', currentTransaction.category.name, icon: currentTransaction.category.icon),
                const Divider(),
                _buildDetailRow('Date', formattedDate, icon: Icons.calendar_today),
                const Divider(),
                _buildDetailRow('Notes', (currentTransaction.notes != null && currentTransaction.notes!.isNotEmpty) ? currentTransaction.notes! : 'No notes provided', icon: Icons.notes),
                const Divider(),

                if (currentTransaction.imagePaths != null && currentTransaction.imagePaths!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentTransaction.imagePaths!.length,
                      itemBuilder: (context, index) {
                        final path = currentTransaction.imagePaths![index];
                        final heroTag = 'image-$path-$index';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenImageViewer(imagePath: path, heroTag: heroTag)));
                            },
                            child: Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(path), width: 120, height: 120, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}