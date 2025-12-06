import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../models/expense.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Boxes.getExpenses().listenable(),
        builder: (context, box, _) {
          final expenses = box.values.toList().cast<Expense>();

          // Filter for current month
          final now = DateTime.now();
          final currentMonthExpenses = expenses
              .where(
                  (e) => e.date.month == now.month && e.date.year == now.year)
              .toList();

          if (currentMonthExpenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses this month!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }

          // Calculate category totals
          final Map<String, double> categoryTotals = {};
          double totalMonthAmount = 0;

          for (var expense in currentMonthExpenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
            totalMonthAmount += expense.amount;
          }

          final currencyFormat =
              NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');

          return Column(
            children: [
              // Total Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF00695C).withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      'Total for ${DateFormat('MMMM y').format(now)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(totalMonthAmount),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ],
                ),
              ),

              // Category List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryTotals.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final category = categoryTotals.keys.elementAt(index);
                    final amount = categoryTotals[category]!;
                    final percentage = (amount / totalMonthAmount);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(category),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        color: _getCategoryColor(category),
                      ),
                      trailing: Text(
                        currencyFormat.format(amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_cart;
      case 'Bills':
        return Icons.receipt;
      case 'Medicine':
        return Icons.medical_services;
      case 'Transport':
        return Icons.directions_bus;
      case 'Shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries':
        return Colors.green;
      case 'Bills':
        return Colors.orange;
      case 'Medicine':
        return Colors.red;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
