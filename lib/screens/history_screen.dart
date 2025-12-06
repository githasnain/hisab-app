import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../models/expense.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Expense History'),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Boxes.getExpenses().listenable(),
        builder: (context, box, _) {
          final expenses = box.values.toList().cast<Expense>();

          // Filter by search query
          final filteredExpenses = expenses.where((expense) {
            final title = expense.title.toLowerCase();
            final category = expense.category.toLowerCase();
            final note = expense.note.toLowerCase();
            return title.contains(_searchQuery) ||
                category.contains(_searchQuery) ||
                note.contains(_searchQuery);
          }).toList();

          if (filteredExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No expenses yet!'
                        : 'No matching expenses',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Sort by date descending
          filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

          // Group by date
          final groupedExpenses = <String, List<Expense>>{};
          for (var expense in filteredExpenses) {
            final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
            if (!groupedExpenses.containsKey(dateKey)) {
              groupedExpenses[dateKey] = [];
            }
            groupedExpenses[dateKey]!.add(expense);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedExpenses.length,
            itemBuilder: (context, index) {
              final dateKey = groupedExpenses.keys.elementAt(index);
              final dayExpenses = groupedExpenses[dateKey]!;
              final date = DateTime.parse(dateKey);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(date, dayExpenses),
                  const SizedBox(height: 8),
                  ...dayExpenses.map(
                      (expense) => _buildExpenseCard(context, expense, box)),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, List<Expense> dayExpenses) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1;

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMM d').format(date);
    }

    final totalAmount = dayExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00695C),
            ),
          ),
          Text(
            currencyFormat.format(totalAmount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
      BuildContext context, Expense expense, Box<Expense> box) {
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () => _deleteExpense(context, expense),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon or Thumbnail
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    image: (expense.imagePaths.isNotEmpty)
                        ? DecorationImage(
                            image: FileImage(File(expense.imagePaths.first)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (expense.imagePaths.isEmpty)
                      ? Icon(
                          _getCategoryIcon(expense.category),
                          color: const Color(0xFF00695C),
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title.isNotEmpty
                            ? expense.title
                            : expense.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (expense.paymentMethod != 'Cash') ...[
                            Icon(
                              expense.paymentMethod == 'Card'
                                  ? Icons.credit_card
                                  : Icons.account_balance,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              expense.note.isNotEmpty
                                  ? expense.note
                                  : expense.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(expense.amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to remove this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Boxes.getExpenses();
              final key = box.keys
                  .firstWhere((k) => box.get(k) == expense, orElse: () => null);
              if (key != null) {
                box.delete(key);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_cart_outlined;
      case 'Bills':
        return Icons.receipt_long_outlined;
      case 'Medicine':
        return Icons.medical_services_outlined;
      case 'Transport':
        return Icons.directions_bus_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Food':
        return Icons.restaurant;
      case 'Rent':
        return Icons.home_work_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
