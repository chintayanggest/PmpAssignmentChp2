import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/unified_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Bumped version to v5 to force clean install for new User columns
    _database = await _initDB('fintrack_v5.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // USERS TABLE (Added profilePath)
    await db.execute('''
      CREATE TABLE users (
        id $idType, 
        name $textType, 
        email $textType, 
        password $textType, 
        preferredCurrency $textType,
        profilePath TEXT
      )
    ''');

    // ACCOUNTS TABLE
    await db.execute('CREATE TABLE accounts (id $idType, userId $textType, name $textType, iconCode $intType, balance $doubleType, FOREIGN KEY (userId) REFERENCES users (id))');

    // TRANSACTIONS TABLE
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        userId $textType,
        amount $doubleType,
        type $intType,
        categoryId $textType,
        accountId $textType,
        date $textType,
        notes TEXT,
        imagePaths TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // GOALS TABLE
    await db.execute('CREATE TABLE goals (id $idType, userId $textType, name $textType, targetAmount $doubleType, currentAmount $doubleType, targetDate $textType, imagePath TEXT, FOREIGN KEY (userId) REFERENCES users (id))');

    // RECURRING TABLE
    await db.execute('CREATE TABLE recurring (id $idType, userId $textType, name $textType, amount $doubleType, category $textType, frequency $textType, nextPaymentDate $textType, FOREIGN KEY (userId) REFERENCES users (id))');
  }

  Future<void> createUser(User user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap());

    // Create ALL Default Accounts
    final List<Map<String, dynamic>> defaultAccounts = [
      {'name': 'Wallet', 'icon': Icons.account_balance_wallet.codePoint},
      {'name': 'GoPay', 'icon': Icons.phone_android.codePoint},
      {'name': 'ShopeePay', 'icon': Icons.shopping_cart.codePoint},
      {'name': 'DANA', 'icon': Icons.credit_card.codePoint},
      {'name': 'OVO', 'icon': Icons.local_offer.codePoint},
      {'name': 'Mobile Banking 1', 'icon': Icons.account_balance.codePoint},
      {'name': 'Mobile Banking 2', 'icon': Icons.account_balance.codePoint},
      {'name': 'Mobile Banking 3', 'icon': Icons.account_balance.codePoint},
      {'name': 'Cash', 'icon': Icons.money.codePoint},
      {'name': 'Credit Card', 'icon': Icons.credit_card_outlined.codePoint},
      {'name': 'Investment', 'icon': Icons.trending_up.codePoint},
      {'name': 'Savings', 'icon': Icons.savings.codePoint},
    ];

    for (var acc in defaultAccounts) {
      await db.insert('accounts', Account(
          id: '${user.id}_${acc['name']!.toString().replaceAll(" ", "")}',
          userId: user.id,
          name: acc['name'] as String,
          iconCode: acc['icon'] as int
      ).toMap());
    }
  }

  Future<User?> getUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // --- UPDATE USER (For Profile Picture) ---
  Future<void> updateUser(User user) async {
    final db = await instance.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // --- DELETE ACCOUNT (Deletes ALL data for that user) ---
  Future<void> deleteUser(String userId) async {
    final db = await instance.database;
    // Cascade delete everything related to this user
    await db.delete('transactions', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('accounts', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('goals', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('recurring', where: 'userId = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}