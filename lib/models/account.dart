import 'package:flutter/material.dart';

class Account {
  final String id;
  final String userId; // Added to link to user
  String name;
  final int iconCode; // Changed to store int for Database
  double balance;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconCode,
    this.balance = 0.0,
  });

  // Helper to get the actual IconData object
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'name': name, 'iconCode': iconCode, 'balance': balance,
  };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    id: map['id'], userId: map['userId'], name: map['name'], iconCode: map['iconCode'], balance: map['balance'],
  );
}