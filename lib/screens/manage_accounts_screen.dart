// lib/screens/manage_accounts_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'edit_account_screen.dart';
// Ensure NO import to ../models/account.dart exists here implicitly or explicitly

class ManageAccountsScreen extends StatelessWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts (Rekening)'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final accounts = provider.accounts;
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: Icon(account.icon, size: 30),
                title: Text(account.name),
                trailing: Text(
                  'Rp${account.balance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAccountScreen(account: account),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}