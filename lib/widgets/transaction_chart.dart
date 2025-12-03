// lib/widgets/transaction_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/unified_models.dart'; // EXCLUSIVE IMPORT

class TransactionChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final TransactionType type;

  const TransactionChart({
    super.key,
    required this.transactions,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = transactions.fold(0.0, (sum, item) => sum + item.amount);

    if (totalValue == 0) {
      return Center(
        child: Text(
          'No ${type == TransactionType.expense ? 'expense' : 'income'} data.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final Map<String, double> categoryValues = {};
    for (var tx in transactions) {
      categoryValues.update(
        tx.category.name,
            (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final List<PieChartSectionData> sections = categoryValues.entries.map((entry) {
      final totalAmount = entry.value;
      final percentage = (totalAmount / totalValue * 100);

      final sampleTx = transactions.firstWhere((t) => t.category.name == entry.key);
      final color = sampleTx.category.color;

      return PieChartSectionData(
        color: color,
        value: totalAmount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 60,
            sectionsSpace: 2,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type == TransactionType.expense ? 'Expenses' : 'Income',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              'Rp${totalValue.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}