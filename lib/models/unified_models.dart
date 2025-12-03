import 'package:flutter/material.dart';

// --- ENUMS ---
enum TransactionType { expense, income }

// --- USER ---
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String preferredCurrency;
  final String? profilePath; // Stores the file path to the profile photo

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.preferredCurrency = 'IDR',
    this.profilePath,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'preferredCurrency': preferredCurrency,
    'profilePath': profilePath,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    password: map['password'],
    preferredCurrency: map['preferredCurrency'],
    profilePath: map['profilePath'],
  );

  // Helper to create a copy of the user with updated fields
  User copyWith({String? name, String? profilePath}) {
    return User(
      id: id,
      email: email,
      password: password,
      preferredCurrency: preferredCurrency,
      name: name ?? this.name,
      profilePath: profilePath ?? this.profilePath,
    );
  }
}

// --- ACCOUNT ---
class Account {
  final String id;
  final String userId;
  String name;
  final int iconCode;
  double balance;

  Account({required this.id, required this.userId, required this.name, required this.iconCode, this.balance = 0.0});

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'name': name, 'iconCode': iconCode, 'balance': balance,
  };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    id: map['id'], userId: map['userId'], name: map['name'], iconCode: map['iconCode'], balance: map['balance'],
  );

  @override
  bool operator ==(Object other) => identical(this, other) || other is Account && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// --- CATEGORY ---
class TransactionCategory {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final TransactionType type;

  TransactionCategory({required this.id, required this.name, required this.iconCode, required this.colorValue, required this.type});

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransactionCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// --- TRANSACTION ---
class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final Account account;
  final DateTime date;
  final String? notes;
  final List<String>? imagePaths;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.account,
    required this.date,
    this.notes,
    this.imagePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type == TransactionType.expense ? 0 : 1,
      'categoryId': category.id,
      'accountId': account.id,
      'date': date.toIso8601String(),
      'notes': notes,
      'imagePaths': imagePaths?.join(','),
    };
  }
}

// --- SAVINGS GOAL ---
class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? imagePath;

  SavingsGoal({required this.id, required this.userId, required this.name, required this.targetAmount, this.currentAmount = 0.0, this.targetDate, this.imagePath});

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'name': name, 'targetAmount': targetAmount, 'currentAmount': currentAmount, 'targetDate': targetDate?.toIso8601String(), 'imagePath': imagePath,
  };

  factory SavingsGoal.fromMap(Map<String, dynamic> map) => SavingsGoal(
    id: map['id'], userId: map['userId'], name: map['name'], targetAmount: map['targetAmount'], currentAmount: map['currentAmount'], targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null, imagePath: map['imagePath'],
  );
}

// --- RECURRING PAYMENT ---
class RecurringPayment {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String category;
  final String frequency;
  final DateTime? nextPaymentDate;

  RecurringPayment({required this.id, required this.userId, required this.name, required this.amount, required this.category, required this.frequency, this.nextPaymentDate});

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'name': name, 'amount': amount, 'category': category, 'frequency': frequency, 'nextPaymentDate': nextPaymentDate?.toIso8601String(),
  };

  factory RecurringPayment.fromMap(Map<String, dynamic> map) => RecurringPayment(
    id: map['id'], userId: map['userId'], name: map['name'], amount: map['amount'], category: map['category'], frequency: map['frequency'], nextPaymentDate: map['nextPaymentDate'] != null ? DateTime.parse(map['nextPaymentDate']) : null,
  );
}