import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ReportService {
  static Future<void> generateMonthlyReport(
      List<Expense> expenses, DateTime month) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    // Filter expenses for the month
    final monthlyExpenses = expenses.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList();

    // Sort by date
    monthlyExpenses.sort((a, b) => a.date.compareTo(b.date));

    final totalAmount = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US', name: 'PKR');
    final dateFormat = DateFormat('dd MMM yyyy');

    // Load Logo (assuming it's in assets)
    // Note: For simplicity in this iteration, we'll use text or a placeholder if asset loading is complex async
    // But we can try to load the asset.
    final logoImage = await rootBundle.load('assets/logo.png');
    final imageBytes = logoImage.buffer.asUint8List();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          buildBackground: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                color: PdfColors.white, // Clean white background
              ),
            );
          },
        ),
        header: (context) => _buildHeader(month, imageBytes, font, boldFont),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildSummary(totalAmount, currencyFormat, boldFont),
          pw.SizedBox(height: 30),
          _buildExpenseTable(
              monthlyExpenses, dateFormat, currencyFormat, font, boldFont),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'hisab_report_${DateFormat('MMM_yyyy').format(month)}.pdf');
  }

  static pw.Widget _buildHeader(
      DateTime month, Uint8List logoBytes, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  height: 50,
                  width: 50,
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
                pw.SizedBox(width: 10),
                pw.Text('Hisab App',
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 24, color: PdfColors.teal)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Monthly Expense History',
                    style: pw.TextStyle(font: boldFont, fontSize: 18)),
                pw.Text(DateFormat('MMMM yyyy').format(month),
                    style: pw.TextStyle(
                        font: font, fontSize: 14, color: PdfColors.grey700)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.teal, thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSummary(
      double total, NumberFormat currencyFormat, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total Expenses',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.Text(currencyFormat.format(total),
              style: pw.TextStyle(
                  font: boldFont, fontSize: 20, color: PdfColors.red900)),
        ],
      ),
    );
  }

  static pw.Widget _buildExpenseTable(
      List<Expense> expenses,
      DateFormat dateFormat,
      NumberFormat currencyFormat,
      pw.Font font,
      pw.Font boldFont) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Category', 'Title', 'Amount'],
      data: expenses.map((e) {
        return [
          dateFormat.format(e.date),
          e.category,
          e.title,
          currencyFormat.format(e.amount),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(color: PdfColors.grey300),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated by Hisab App',
                style: pw.TextStyle(
                    font: font, fontSize: 10, color: PdfColors.grey600)),
            pw.Text('Developed by Hasnain Haider',
                style: pw.TextStyle(
                    font: font, fontSize: 10, color: PdfColors.grey600)),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                    font: font, fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }
}
