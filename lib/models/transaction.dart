import 'transaction_category.dart';
import 'transaction_type.dart';
import 'account.dart';

class Transaction {
  final String id;
  final String userId; // Added to link to user
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final Account account;
  final DateTime date;
  final String? notes;
  final List<String>? imagePaths;

  Transaction({
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
      'categoryId': category.id, // Store ID only
      'accountId': account.id,   // Store ID only
      'date': date.toIso8601String(),
      'notes': notes,
      'imagePaths': imagePaths?.join(','),
    };
  }
}