// lib/providers/transaction_provider.dart

import 'package:flutter/material.dart';
import '../models/unified_models.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<Account> _accounts = [];

  // CATEGORIES LIST (Kept same as before)
  final List<TransactionCategory> _categories = [
    TransactionCategory(id: 'e1', name: 'Food', iconCode: Icons.fastfood.codePoint, colorValue: Colors.orange.value, type: TransactionType.expense),
    TransactionCategory(id: 'e2', name: 'Transport', iconCode: Icons.directions_car.codePoint, colorValue: Colors.blue.value, type: TransactionType.expense),
    TransactionCategory(id: 'e3', name: 'Shopping', iconCode: Icons.shopping_bag.codePoint, colorValue: Colors.pink.value, type: TransactionType.expense),
    TransactionCategory(id: 'e4', name: 'Bills', iconCode: Icons.receipt.codePoint, colorValue: Colors.green.value, type: TransactionType.expense),
    TransactionCategory(id: 'e5', name: 'Health', iconCode: Icons.healing.codePoint, colorValue: Colors.red.value, type: TransactionType.expense),
    TransactionCategory(id: 'e6', name: 'Housing', iconCode: Icons.house.codePoint, colorValue: Colors.brown.value, type: TransactionType.expense),
    TransactionCategory(id: 'e7', name: 'Education', iconCode: Icons.school.codePoint, colorValue: Colors.indigo.value, type: TransactionType.expense),
    TransactionCategory(id: 'e8', name: 'Entertainment', iconCode: Icons.movie.codePoint, colorValue: Colors.purple.value, type: TransactionType.expense),
    TransactionCategory(id: 'e9', name: 'Beauty', iconCode: Icons.face.codePoint , colorValue: Colors.pinkAccent.value , type: TransactionType.expense),
    TransactionCategory(id: 'e10', name: 'Other', iconCode: Icons.more_horiz.codePoint, colorValue: Colors.grey.value, type: TransactionType.expense),
    TransactionCategory(id: 'i1', name: 'Salary', iconCode: Icons.work.codePoint, colorValue: Colors.green.value, type: TransactionType.income),
    TransactionCategory(id: 'i2', name: 'Gifts', iconCode: Icons.card_giftcard.codePoint, colorValue: Colors.red.value, type: TransactionType.income),
    TransactionCategory(id: 'i3', name: 'Investment', iconCode: Icons.trending_up.codePoint, colorValue: Colors.blue.value, type: TransactionType.income),
    TransactionCategory(id: 'i4', name: 'Freelance', iconCode: Icons.laptop_mac.codePoint, colorValue: Colors.teal.value, type: TransactionType.income),
    TransactionCategory(id: 'i5', name: 'Business', iconCode: Icons.business.codePoint, colorValue: Colors.cyan.value, type: TransactionType.income),
    TransactionCategory(id: 'i6', name: 'Rental', iconCode: Icons.real_estate_agent.codePoint, colorValue: Colors.amber.value, type: TransactionType.income),
    TransactionCategory(id: 'i7', name: 'Awards', iconCode: Icons.emoji_events.codePoint, colorValue: Colors.yellow.value, type: TransactionType.income),
    TransactionCategory(id: 'i8', name: 'Grants', iconCode: Icons.account_balance.codePoint, colorValue: Colors.lightGreen.value, type: TransactionType.income),
    TransactionCategory(id: 'i9', name: 'Other', iconCode: Icons.more_horiz.codePoint, colorValue: Colors.grey.value, type: TransactionType.income),
  ];

  List<TransactionModel> get transactions => _transactions;
  List<Account> get accounts => _accounts;
  List<TransactionCategory> get categories => _categories;
  List<TransactionCategory> getCategoriesByType(TransactionType type) { return _categories.where((c) => c.type == type).toList(); }

  double get totalBalance => _accounts.fold(0.0, (sum, account) => sum + account.balance);

  // --- DATABASE OPERATIONS ---

  Future<void> fetchData(String userId) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Fetch Accounts
    final accResult = await db.query('accounts', where: 'userId = ?', whereArgs: [userId]);
    _accounts = accResult.map((e) => Account.fromMap(e)).toList();

    // 2. Fetch Transactions
    final txResult = await db.query('transactions', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');

    _transactions = [];
    for (var row in txResult) {
      final account = _accounts.firstWhere(
              (a) => a.id == row['accountId'],
          orElse: () => _accounts.isNotEmpty ? _accounts[0] : Account(id: 'temp', userId: userId, name: 'Unknown', iconCode: 0)
      );

      final category = _categories.firstWhere(
              (c) => c.id == row['categoryId'],
          orElse: () => _categories[0]
      );

      _transactions.add(TransactionModel(
        id: row['id'] as String,
        userId: row['userId'] as String,
        amount: row['amount'] as double,
        type: (row['type'] as int) == 0 ? TransactionType.expense : TransactionType.income,
        category: category,
        account: account,
        date: DateTime.parse(row['date'] as String),
        notes: row['notes'] as String?,
        imagePaths: (row['imagePaths'] as String?)?.split(',').where((e) => e.isNotEmpty).toList(),
      ));
    }
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('transactions', tx.toMap());

    // Update the Account Balance in DB
    final account = _accounts.firstWhere((acc) => acc.id == tx.account.id);
    double newBalance = tx.type == TransactionType.income
        ? account.balance + tx.amount
        : account.balance - tx.amount;

    await db.update(
        'accounts',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [account.id]
    );

    await fetchData(tx.userId);
  }

  // --- FIXED: Delete Transaction and Sync Balance ---
  Future<void> deleteTransaction(String id) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Find the transaction in the local list before deleting
    final txToDelete = _transactions.firstWhere((t) => t.id == id);

    // 2. Find the associated account
    final account = _accounts.firstWhere((acc) => acc.id == txToDelete.account.id);

    // 3. Reverse the balance calculation
    // If it was Income, we subtract. If it was Expense, we add it back.
    double newBalance = txToDelete.type == TransactionType.income
        ? account.balance - txToDelete.amount
        : account.balance + txToDelete.amount;

    // 4. Update Account in DB
    await db.update(
        'accounts',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [account.id]
    );

    // 5. Delete the Transaction from DB
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

    // 6. Refresh UI
    await fetchData(txToDelete.userId);
  }

  Future<void> updateAccount({required String id, required String newName, required double newBalance}) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
        'accounts',
        {'name': newName, 'balance': newBalance},
        where: 'id = ?',
        whereArgs: [id]
    );

    final acc = _accounts.firstWhere((a) => a.id == id);
    await fetchData(acc.userId);
  }
}