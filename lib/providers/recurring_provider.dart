// lib/providers/recurring_provider.dart

import 'package:flutter/material.dart';
import '../models/unified_models.dart';
import '../services/database_helper.dart';

class RecurringProvider with ChangeNotifier {
  List<RecurringPayment> _payments = [];

  List<RecurringPayment> get payments => _payments;

  Future<void> fetchPayments(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('recurring', where: 'userId = ?', whereArgs: [userId]);
    _payments = result.map((json) => RecurringPayment.fromMap(json)).toList();
    notifyListeners();
  }

  Future<void> addPayment(RecurringPayment payment) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('recurring', payment.toMap());
    await fetchPayments(payment.userId);
  }

  Future<void> deletePayment(String id, String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('recurring', where: 'id = ?', whereArgs: [id]);
    await fetchPayments(userId);
  }

  // --- NEW METHOD FOR EDITING ---
  Future<void> updatePayment(RecurringPayment payment) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'recurring',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
    await fetchPayments(payment.userId);
  }
}