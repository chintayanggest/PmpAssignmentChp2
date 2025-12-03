import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/unified_models.dart';
import '../providers/goal_provider.dart';
import '../providers/auth_provider.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<GoalProvider>(context, listen: false).fetchGoals(user.id);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access data from Provider
    final goalProvider = Provider.of<GoalProvider>(context);
    final goals = goalProvider.goals;

    double totalSaved = goals.fold(0, (sum, item) => sum + item.currentAmount);
    double totalTarget = goals.fold(0, (sum, item) => sum + item.targetAmount);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Savings Goals', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        automaticallyImplyLeading: false, // Hide back button on main tabs
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFC6FF00)))
            : goals.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildMainCard(goals.length, totalSaved, totalTarget),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your Goals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: goals.map((goal) => _buildGoalCard(goal)).toList(),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        backgroundColor: const Color(0xFFC6FF00),
        child: const Icon(Icons.add, size: 28, color: Color(0xFF121212)),
      ),
    );
  }

  Widget _buildMainCard(int count, double totalSaved, double totalTarget) {
    final overallProgress = totalTarget > 0 ? totalSaved / totalTarget : 0.0;
    final progressPercentage = (overallProgress * 100).clamp(0, 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFC6FF00),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC6FF00).withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Color(0xFFC6FF00), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Color(0xFFC6FF00),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: overallProgress > 1 ? 1 : overallProgress,
                  strokeWidth: 35,
                  backgroundColor: const Color(0xFF121212).withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF121212)),
                ),
              ),
              Text(
                '$progressPercentage%',
                style: const TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(totalSaved)}',
                style: const TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total Savings',
                style: TextStyle(color: Color(0xFF121212), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, size: 80, color: Color(0xFFC6FF00)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Goals Yet',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Start saving for your dreams!', style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final progressPercentage = (goal.progress * 100).clamp(0, 100).toInt();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFC6FF00),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image logic simplified for now
            if (goal.imagePath != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.file(
                  File(goal.imagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const SizedBox(height: 0), // Hide if error
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$progressPercentage%',
                        style: const TextStyle(
                          color: Color(0xFF121212),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(goal.currentAmount)} / Rp ${NumberFormat('#,###', 'id_ID').format(goal.targetAmount)}',
                    style: const TextStyle(color: Color(0xFF121212)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}