// lib/screens/category_transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unified_models.dart'; // EXCLUSIVE IMPORT
// REMOVED: import '../models/transaction_category.dart';
// REMOVED: import '../models/transaction.dart';
// REMOVED: import '../models/transaction_type.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_screen.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  final TransactionCategory category;

  const CategoryTransactionsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Filter transactions by category ID
    final transactions = provider.transactions
        .where((tx) => tx.category.id == category.id)
        .toList();

    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // Group by Date
    final Map<DateTime, List<TransactionModel>> groupedTransactions = {};
    for (var tx in transactions) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    final groupedList = groupedTransactions.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: category.color, // Using Color object from unified model
      ),
      body: ListView.builder(
        itemCount: groupedList.length,
        itemBuilder: (context, index) {
          final dateEntry = groupedList[index];
          final date = dateEntry.key;
          final dailyTransactions = dateEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DATE HEADER
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${date.day} ${_months[date.month - 1]} ${date.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // TRANSACTIONS LIST
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: dailyTransactions.length,
                itemBuilder: (context, txIndex) {
                  final transaction = dailyTransactions[txIndex];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.category.color.withOpacity(0.2),
                      child: Icon(transaction.category.icon, color: transaction.category.color),
                    ),
                    title: Text(transaction.account.name),
                    subtitle: Text(transaction.notes ?? 'No notes'),
                    trailing: Text(
                      '${transaction.type == TransactionType.expense ? '-' : '+'}Rp${transaction.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: transaction.type == TransactionType.expense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(transaction: transaction),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}

const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];