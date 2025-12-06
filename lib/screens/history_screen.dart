import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../models/expense.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Boxes.getExpenses().listenable(),
        builder: (context, box, _) {
          final expenses = box.values.toList().cast<Expense>();

          // Sort by date descending (newest first)
          expenses.sort((a, b) => b.date.compareTo(a.date));

          if (expenses.isEmpty) {
            return const Center(
              child: Text(
                'No expenses yet!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _buildExpenseCard(context, expense, box, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(
      BuildContext context, Expense expense, Box<Expense> box, int index) {
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00695C).withValues(alpha: 0.1),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: const Color(0xFF00695C),
          ),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(expense.date)),
            if (expense.note.isNotEmpty)
              Text(
                expense.note,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F), // Red for expense
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _deleteExpense(context, expense),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Find the key of the expense to delete it
              // Since we're iterating a list, we need to find the key in the box
              final box = Boxes.getExpenses();
              final key = box.keys
                  .firstWhere((k) => box.get(k) == expense, orElse: () => null);
              if (key != null) {
                box.delete(key);
              }
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
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
}
