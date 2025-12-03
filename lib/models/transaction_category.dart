import 'package:flutter/material.dart';
import 'transaction_type.dart'; // We need this for the TransactionType enum

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon; // This will hold the icon for the category
  final Color color;   // This will hold the color for the category
  final TransactionType type; // Is it an Expense or Income category?

  TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}