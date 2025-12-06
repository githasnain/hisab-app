import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../boxes.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  void _refreshExpense() {
    final box = Boxes.getExpenses();
    final freshExpense = box.values.firstWhere(
      (e) => e.id == _expense.id,
      orElse: () => _expense,
    );
    setState(() {
      _expense = freshExpense;
    });
  }

  Future<void> _saveReceipt() async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'receipt_${_expense.id}.png';
      final path = '${directory.path}/$fileName';

      // Capture the hidden widget directly
      final capturedImage = await _screenshotController.captureAndSave(
        directory.path,
        fileName: fileName,
        pixelRatio: 3.0,
      );

      if (capturedImage != null) {
        await Gal.putImage(path, album: 'Hisab Receipts');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Receipt saved to Gallery (Hisab Receipts)!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving receipt: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddExpenseScreen(expenseToEdit: _expense),
                ),
              ).then((_) {
                _refreshExpense(); // Refresh UI and data after edit
              });
            },
            tooltip: 'Edit Expense',
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveReceipt,
            tooltip: 'Save Receipt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Receipt Widget to Capture
            Screenshot(
              controller: _screenshotController,
              child: _buildReceiptContent(),
            ),

            const SizedBox(height: 24),

            // Photos Section (Outside Receipt)
            if (_expense.imagePaths.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Attached Photos',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _expense.imagePaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_expense.imagePaths[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptContent() {
    const primaryColor = Color(0xFF2C3E50); // Dark Slate Blue

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Icon
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: primaryColor,
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'PAYMENT RECEIPT',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF454545),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM d, yyyy  h:mm a').format(_expense.date),
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // Total Amount
          Text(
            'TOTAL AMOUNT:',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR')
                .format(_expense.amount),
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // Details List
          _buildDetailRow('Category:', _expense.category),
          _buildDetailRow('Payment Method:', _expense.paymentMethod),
          if (_expense.title.isNotEmpty)
            _buildDetailRow('Item:', _expense.title),
          if (_expense.note.isNotEmpty) _buildDetailRow('Note:', _expense.note),

          const SizedBox(height: 16),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 24),

          // New Stamp Design (Smaller)
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                ),
                // Inner Ring
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                ),
                // Text
                Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.white,
                    child: Text(
                      'HISAB',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                // Sparkle Icon
                Positioned(
                  top: 18,
                  right: 18,
                  child: Icon(
                    Icons.auto_awesome,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Simple Footer
          Text(
            'developed by Hasnain Haider',
            style: GoogleFonts.dancingScript(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF454545),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
