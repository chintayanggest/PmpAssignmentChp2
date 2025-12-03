import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the list of categories and rebuild when it changes
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Categories'),
          ),
          body: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color.withOpacity(0.2),
                  child: Icon(category.icon, color: category.color),
                ),
                title: Text(category.name),
                // Display whether it's an Income or Expense category
                trailing: Text(
                  category.type.toString().split('.').last, // This gets 'income' or 'expense'
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}