import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../models/expense.dart';
import '../services/report_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Cream
      appBar: AppBar(
        title: const Text('Monthly Summary'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF8E1), // Cream
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final box = Boxes.getExpenses();
          final expenses = box.values.toList().cast<Expense>();
          _generateReport(expenses);
        },
        label: const Text('Download Report'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white, // Fix contrast
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Boxes.getExpenses().listenable(),
        builder: (context, box, _) {
          final expenses = box.values.toList().cast<Expense>();

          // Filter for selected month
          final currentMonthExpenses = expenses
              .where((e) =>
                  e.date.month == _selectedMonth.month &&
                  e.date.year == _selectedMonth.year)
              .toList();

          // Calculate totals
          final Map<String, double> categoryTotals = {};
          double totalMonthAmount = 0;

          for (var expense in currentMonthExpenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
            totalMonthAmount += expense.amount;
          }

          // Sort categories by amount descending
          final sortedCategories = categoryTotals.keys.toList()
            ..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));

          return ValueListenableBuilder<Box>(
            valueListenable: Boxes.getSettings().listenable(),
            builder: (context, settingsBox, _) {
              final budget =
                  settingsBox.get('monthly_budget', defaultValue: 0.0);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTotalCard(
                        context, totalMonthAmount, budget, settingsBox),
                    if (currentMonthExpenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.pie_chart_outline,
                                size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses this month',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category Breakdown',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7043), // Coral
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...sortedCategories.map((category) {
                              final amount = categoryTotals[category]!;
                              return _buildCategoryItem(
                                  category, amount, totalMonthAmount);
                            }),
                          ],
                        ),
                      ),
                    // Bottom padding for FAB
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTotalCard(
      BuildContext context, double total, double budget, Box settingsBox) {
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');

    double rawProgress = 0.0;
    double progress = 0.0;
    Color progressColor = Colors.green;
    String statusText = '';

    if (budget > 0) {
      rawProgress = total / budget;
      progress = rawProgress > 1.0 ? 1.0 : rawProgress;

      if (rawProgress > 1.0) {
        progressColor = Colors.red;
        statusText = 'Over budget by ${currencyFormat.format(total - budget)}';
      } else {
        statusText = '${(rawProgress * 100).toInt()}% used';
        if (rawProgress > 0.9) {
          progressColor = Colors.orange;
        } else if (rawProgress > 0.7) {
          progressColor = Colors.amber;
        }
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFFAB91)], // Coral to Soft Coral
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7043).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white70, size: 20),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                DateFormat('MMMM y').format(_selectedMonth),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 20),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Total Amount with scaling
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyFormat.format(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Budget Section
          InkWell(
            onTap: () => _showSetBudgetDialog(context, settingsBox, budget),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            budget > 0
                                ? currencyFormat.format(budget)
                                : 'Tap to set',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit,
                              color: Colors.white70, size: 16),
                        ],
                      ),
                    ],
                  ),
                  if (budget > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        color: progressColor,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, double total) {
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');
    final percentage = amount / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormat.format(amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade100,
                    color: _getCategoryColor(category),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(
      BuildContext context, Box settingsBox, double currentBudget) {
    final controller = TextEditingController(
        text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Budget Amount (PKR)',
            prefixText: 'Rs ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text) ?? 0.0;
              settingsBox.put('monthly_budget', newBudget);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7043), // Coral
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('SAVE'),
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
      case 'Food':
        return Colors.amber;
      case 'Rent':
        return Colors.indigo;
      default:
        return Colors.teal;
    }
  }

  Future<void> _generateReport(List<Expense> expenses) async {
    await ReportService.generateMonthlyReport(expenses, _selectedMonth);
  }
}
