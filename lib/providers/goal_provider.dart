import 'package:flutter/material.dart';
import '../models/unified_models.dart';
import '../services/database_helper.dart';


class GoalProvider with ChangeNotifier {
  List<SavingsGoal> _goals = [];

  List<SavingsGoal> get goals => _goals;

  Future<void> fetchGoals(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('goals', where: 'userId = ?', whereArgs: [userId]);
    _goals = result.map((json) => SavingsGoal.fromMap(json)).toList();
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('goals', goal.toMap());
    await fetchGoals(goal.userId);
  }

  Future<void> updateGoalProgress(String id, double newCurrentAmount, String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'goals',
      {'currentAmount': newCurrentAmount},
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchGoals(userId);
  }

  Future<void> deleteGoal(String id, String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    await fetchGoals(userId);
  }
}