import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import 'custom_gold_button.dart';

class ReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> donationDetails;

  const ReceiptDialog({super.key, required this.donationDetails});

  void _generateAndPrintPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SWEEZEN FOUNDATION', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.Text('SECTION 8 NON-PROFIT | UN SDG ALIGNED', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          pw.Text('Reg. No: REG/SECTION-8/SDG-2024-9901 | PAN: AAATS8891G', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.Text('80G TAX E-RECEIPT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('OFFICIAL DONATION RECEIPT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 15),

                pw.TableHelper.fromTextArray(
                  context: ctx,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  data: <List<String>>[
                    <String>['Field', 'Details'],
                    <String>['Receipt Number', donationDetails['receiptId'] ?? 'SWZ-RCPT-8891'],
                    <String>['Transaction ID', donationDetails['txnId'] ?? 'TXN_SWZ_98231'],
                    <String>['Date', DateTime.now().toString().split(' ')[0]],
                    <String>['Donor Name', donationDetails['donor_name'] ?? 'Generous Supporter'],
                    <String>['Donor PAN', donationDetails['pan_number'] ?? 'NOT_PROVIDED'],
                    <String>['Amount Donated', 'INR ₹${donationDetails['amount'] ?? 1000}'],
                    <String>['Program Allocated', donationDetails['project_name'] ?? 'General Foundation Fund'],
                    <String>['80G Exemption Status', 'Eligible for 50% Tax Deduction under Sec 80G'],
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('80G Approval Reference: 80G/CIT(E)/DELHI/2024-25/A-10892', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Thank you for empowering rural healthcare, education, and environmental sustainability.', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                    children: [
                      pw.Text('Authorized Signatory', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Sweezen Foundation Board', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.goldAccent.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.verified, color: AppTheme.amberGold, size: 24),
                      SizedBox(width: 8),
                      Text('80G Tax E-Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),

              // Receipt Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Receipt ID:', donationDetails['receiptId'] ?? 'SWZ-RCPT-8891'),
                    _buildReceiptRow('Donor Name:', donationDetails['donor_name'] ?? 'Generous Donor'),
                    _buildReceiptRow('PAN Number:', donationDetails['pan_number'] ?? 'ABCDE1234F'),
                    _buildReceiptRow('Amount Paid:', '₹${donationDetails['amount'] ?? 1000}', isGold: true),
                    _buildReceiptRow('Tax Benefit:', '50% Deduction under Sec 80G', isGreen: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'This receipt has been generated automatically and registered with the Income Tax Department for Sec 80G tax rebate.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomGoldButton(
                      text: 'DOWNLOAD PDF / PRINT',
                      icon: Icons.picture_as_pdf,
                      onPressed: () => _generateAndPrintPdf(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isGold = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: isGold ? AppTheme.amberGold : (isGreen ? AppTheme.successGreen : Colors.white),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
