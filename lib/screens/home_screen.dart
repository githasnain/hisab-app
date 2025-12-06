import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Expense Manager'),
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: Boxes.getExpenses().listenable(),
        builder: (context, box, _) {
          final expenses = box.values.toList().cast<Expense>();

          // Calculate current month total
          final now = DateTime.now();
          final currentMonthExpenses = expenses
              .where(
                  (e) => e.date.month == now.month && e.date.year == now.year)
              .toList();

          final totalAmount =
              currentMonthExpenses.fold(0.0, (sum, item) => sum + item.amount);
          final currencyFormat = NumberFormat.simpleCurrency(
              locale: 'en_US',
              name: 'PKR'); // Assuming PKR based on name "Hisab"

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child:
                            Image.asset('assets/logo.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),

                // Monthly Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'This Month Total',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currencyFormat.format(totalAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Action Buttons
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 1,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.5,
                    children: [
                      _buildMenuButton(
                        context,
                        'Add Expense',
                        Icons.add_circle_outline,
                        const Color(0xFF00695C),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddExpenseScreen()),
                        ),
                      ),
                      _buildMenuButton(
                        context,
                        'View History',
                        Icons.history,
                        const Color(0xFF1565C0),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HistoryScreen()),
                        ),
                      ),
                      _buildMenuButton(
                        context,
                        'Monthly Summary',
                        Icons.pie_chart_outline,
                        const Color(0xFF6A1B9A),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SummaryScreen()),
                        ),
                      ),
                    ],
                  ),
                ),

                // Developer Footer
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Develop by Hasnain Haider with ❤️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
