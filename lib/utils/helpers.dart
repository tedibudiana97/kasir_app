import 'package:flutter/material.dart';  // ← TAMBAHKAN INI!
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Helpers {
  static String formatCurrency(double amount) {
    return 'Rp ${NumberFormat('#,##0').format(amount)}';
  }

  static String formatCurrencySimple(double amount) {
    return 'Rp ${NumberFormat('#,##0').format(amount)}';
  }

  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateOnly(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String generateInvoiceNumber(int index) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyMMdd').format(now);
    final random = (index + 1).toString().padLeft(4, '0');
    return 'INV-$dateStr-$random';
  }

  // ============================================================
  // CETAK STRUK
  // ============================================================
  static Future<void> printReceipt({
    required BuildContext context,
    required String invoice,
    required String date,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double diskon,
    required double pajak,
    required double total,
    required String paymentMethod,
    required String cashier,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          margin: pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  '🧾 KASIR PREMIUM',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Jl. Contoh No. 123',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Telp: (021) 123-4567',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('INVOICE:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(invoice, style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Tanggal:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(date, style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kasir:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(cashier, style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Item', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Qty', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Harga', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Total', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),

                ...items.map((item) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(item['name'] ?? '-', style: pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('${item['qty'] ?? 0}', style: pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          Helpers.formatCurrencySimple(item['price'] ?? 0),
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          Helpers.formatCurrencySimple(item['total'] ?? 0),
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(Helpers.formatCurrencySimple(subtotal), style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                if (diskon > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Diskon ${diskon.toStringAsFixed(0)}%:', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('-${Helpers.formatCurrencySimple(subtotal * diskon / 100)}', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                if (pajak > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Pajak ${pajak.toStringAsFixed(0)}%:', style: pw.TextStyle(fontSize: 10)),
                      pw.Text(Helpers.formatCurrencySimple(subtotal * pajak / 100), style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      Helpers.formatCurrencySimple(total),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Pembayaran:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(paymentMethod, style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Terima kasih!',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Barang yang sudah dibeli tidak dapat dikembalikan',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  DateTime.now().toString(),
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            );
          },
        ),
      );

      // ============================================================
      // TAMPILKAN DIALOG PILIHAN
      // ============================================================
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Cetak Struk'),
            content: const Text('Pilih aksi untuk struk:'),
            actions: [
              TextButton(
                onPressed: () async {
                  await Printing.sharePdf(
                    bytes: await pdf.save(),
                    filename: 'Struk_$invoice.pdf',
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('📤 Share PDF'),
              ),
              TextButton(
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdf.save(),
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('🖨️ Print'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('❌ Tutup'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      print('Error printing receipt: $e');
    }
  }

    // ============================================================
    // FORMAT BULAN
    // ============================================================
    static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'id').format(date);
    }

    static List<String> getMonths() {
    return [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
  }
}