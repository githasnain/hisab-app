import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  Future<void> _saveReceipt() async {
    setState(() => _isSaving = true);

    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'receipt_${widget.expense.id}.png';
      final path = '${directory.path}/$fileName';

      final capturedImage = await _screenshotController.captureAndSave(
        directory.path,
        fileName: fileName,
        pixelRatio: 3.0,
      );

      if (capturedImage != null) {
        await Gal.putImage(path, album: 'Hisab Receipts');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt saved to Gallery!')),
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
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: const Color(0xFFFF7043),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PAYMENT RECEIPT',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMMM d, yyyy  h:mm a')
                          .format(widget.expense.date),
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
                          .format(widget.expense.amount),
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    const Divider(height: 40, thickness: 1),

                    // Details
                    _buildDetailRow('Category', widget.expense.category),
                    _buildDetailRow(
                        'Payment Method', widget.expense.paymentMethod),
                    if (widget.expense.title.isNotEmpty)
                      _buildDetailRow('Item', widget.expense.title),
                    if (widget.expense.note.isNotEmpty)
                      _buildDetailRow('Note', widget.expense.note),

                    const SizedBox(height: 40),

                    // Stamp
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFFF7043), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      transform: Matrix4.rotationZ(-0.1),
                      child: Text(
                        'Hisab\nDeveloped by Hasnain Haider',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.courierPrime(
                          color: const Color(0xFFFF7043),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Thank you!',
                      style: GoogleFonts.dancingScript(
                        fontSize: 24,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Photos Section (Outside Receipt)
            if (widget.expense.imagePaths.isNotEmpty) ...[
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
                  itemCount: widget.expense.imagePaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image:
                              FileImage(File(widget.expense.imagePaths[index])),
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
