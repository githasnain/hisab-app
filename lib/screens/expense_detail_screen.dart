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
  bool _isSaving = false;
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
    setState(() => _isSaving = true);

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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
            onPressed: _isSaving ? null : _saveReceipt,
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
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(0), // Sharp edges for paper look
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
                    // Header
                    const Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Color(0xFFFF7043),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSaving ? 'PAYMENT RECEIPT' : 'EXPENSE DETAIL',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMMM d, yyyy  h:mm a').format(_expense.date),
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(height: 40, thickness: 1),

                    // Amount
                    Text(
                      'TOTAL AMOUNT',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR')
                          .format(_expense.amount),
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    const Divider(height: 40, thickness: 1),

                    // Details
                    _buildDetailRow('Category', _expense.category),
                    _buildDetailRow('Payment Method', _expense.paymentMethod),
                    if (_expense.title.isNotEmpty)
                      _buildDetailRow('Item', _expense.title),
                    if (_expense.note.isNotEmpty)
                      _buildDetailRow('Note', _expense.note),

                    // Stamp (Only visible on Receipt)
                    if (_isSaving) ...[
                      const SizedBox(height: 40),
                      // Circular Digital Stamp
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFF7043)
                                  .withValues(alpha: 0.8),
                              width: 3),
                        ),
                        transform: Matrix4.rotationZ(-0.2),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Ring Text (Simulated with positioning)
                            Positioned(
                              top: 10,
                              child: Text(
                                'HISAB APP',
                                style: GoogleFonts.courierPrime(
                                  color: const Color(0xFFFF7043)
                                      .withValues(alpha: 0.8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              child: Text(
                                'VERIFIED',
                                style: GoogleFonts.courierPrime(
                                  color: const Color(0xFFFF7043)
                                      .withValues(alpha: 0.8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            // Center Star
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    color: const Color(0xFFFF7043)
                                        .withValues(alpha: 0.8),
                                    size: 24),
                                Text(
                                  'APPROVED',
                                  style: GoogleFonts.courierPrime(
                                    color: const Color(0xFFFF7043)
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 40),
                      const Divider(color: Colors.grey, thickness: 0.5),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Generated by Hisab App',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            'Developed by Hasnain Haider',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Thank You!',
                            style: GoogleFonts.dancingScript(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3142),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
