import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/booking.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:frontend/services/api_services.dart';

// ─── Colors (PDF) ───
const _pBlue = PdfColor.fromInt(0xFF3B82F6);
const _pLightBlue = PdfColor.fromInt(0xFFEFF6FF);
const _pDark = PdfColor.fromInt(0xFF1E293B);
const _pMuted = PdfColor.fromInt(0xFF94A3B8);
const _pWhite = PdfColors.white;

// ─── Preview Screen ───
class ReceiptPreviewScreen extends StatelessWidget {
  const ReceiptPreviewScreen({super.key, required this.doc});

  final pw.Document doc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text("Receipt Preview", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: PdfPreview(
        build: (format) => doc.save(),
        allowSharing: true,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        // canDebug: false,
      ),
    );
  }
}

// ─── Public entry point ───
Future<void> showReceiptPreview(BuildContext context, Booking booking) async {
  // loading while building PDF
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final doc = await _buildReceiptPdf(booking);

    if (!context.mounted) return;
    Navigator.pop(context); // dismiss loader

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPreviewScreen(doc: doc)),
    );
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context); // dismiss loader
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate receipt: $e')));
    }
  }
}

// ─── PDF builder ───
Future<pw.Document> _buildReceiptPdf(Booking booking) async {
  final doc = pw.Document();

  // Go.in logo
  final logoBytes = (await rootBundle.load(
    // byte data
    'assets/images/logo-full.png',
  )).buffer.asUint8List(); // raw bytes / array of bytes
  final logoImage = pw.MemoryImage(logoBytes); // byte -> image in pdf

  // User info
  String userName = '';
  String userEmail = '';
  try {
    final response = await ApiService.getUser();
    final userData = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    userName = userData['username']?.toString() ?? '';
    userEmail = userData['email']?.toString() ?? '';
  } catch (error) {
    debugPrint('Failed to load receipt user: $error');
    // fallback: leave blank if fetch fails
  }

  // Build item rows from booking details
  final items = _buildItems(booking);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      build: (ctx) => [
        _buildHeader(logoImage),
        pw.SizedBox(height: 16),
        _buildBookingSection(booking),
        pw.SizedBox(height: 10),
        _buildMetaSection(booking, userName, userEmail),
        pw.SizedBox(height: 16),
        _buildItemsTable(items, booking.totalPrice),
        pw.SizedBox(height: 24),
        _buildFooter(),
      ],
    ),
  );

  return doc;
}

// ─── Section builders ───

pw.Widget _buildHeader(pw.MemoryImage logo) {
  return pw.Column(
    children: [
      pw.Center(child: pw.Image(logo, height: 48)),
      pw.SizedBox(height: 10),
      pw.Divider(color: _pBlue, thickness: 1.2),
    ],
  );
}

pw.Widget _buildBookingSection(Booking booking) {
  final qrData = booking.qrCode.isNotEmpty
      ? booking.qrCode
      : booking.bookingNumber;

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Left: check-in/out/hotel
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Booking Details',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 13,
                color: _pDark,
              ),
            ),
            pw.SizedBox(height: 8),
            _infoRow('Check in', _fmtDate(booking.checkIn)),
            pw.SizedBox(height: 5),
            _infoRow('Check out', _fmtDate(booking.checkOut)),
            pw.SizedBox(height: 5),
            _infoRow('Hotel', booking.hotelName ?? 'Hotel'),
          ],
        ),
      ),
      // Right: QR code
      pw.BarcodeWidget(
        barcode: pw.Barcode.qrCode(
          errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
        ),
        data: qrData,
        width: 80,
        height: 80,
      ),
    ],
  );
}

/// Booking number / booked at / booked by rows
pw.Widget _buildMetaSection(
  Booking booking,
  String userName,
  String userEmail,
) {
  return pw.Column(
    children: [
      pw.Divider(color: _pMuted, thickness: 0.5),
      pw.SizedBox(height: 8),
      _labelValueRow('Booking Number', booking.bookingNumber),
      pw.SizedBox(height: 5),
      _labelValueRow('Booked at', _fmtDateTime(booking.updatedAt)),
      pw.SizedBox(height: 5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Booked By',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: _pDark,
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                userName.isNotEmpty ? userName : '-',
                style: pw.TextStyle(fontSize: 11, color: _pDark),
              ),
              if (userEmail.isNotEmpty && userEmail != userName)
                pw.Text(
                  userEmail,
                  style: pw.TextStyle(fontSize: 9.5, color: _pMuted),
                ),
            ],
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildItemsTable(List<_ReceiptItem> items, double grandTotal) {
  const headerStyle = pw.TextStyle(color: _pWhite);
  const cellStyle = pw.TextStyle(color: _pDark);

  pw.Widget cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    pw.TextStyle? style,
    PdfColor? bg,
    bool bold = false,
  }) {
    final s =
        style ??
        (bold
            ? pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: _pDark,
                fontSize: 11,
              )
            : cellStyle.copyWith(fontSize: 11));
    return pw.Container(
      color: bg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(text, style: s, textAlign: align),
    );
  }

  pw.TableRow headerRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _pBlue),
      children: [
        cell('Qty', style: headerStyle, align: pw.TextAlign.center),
        cell('Description', style: headerStyle),
        cell('Unit Price', style: headerStyle, align: pw.TextAlign.right),
        cell('Total', style: headerStyle, align: pw.TextAlign.right),
      ],
    );
  }

  pw.TableRow itemRow(_ReceiptItem item, bool alt) {
    final bg = alt ? _pLightBlue : _pWhite;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        cell(item.qty.toString(), align: pw.TextAlign.center),
        cell(item.description),
        cell(_fmtRupiah(item.unitPrice), align: pw.TextAlign.right),
        cell(_fmtRupiah(item.total), align: pw.TextAlign.right),
      ],
    );
  }

  pw.TableRow totalRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _pLightBlue),
      children: [
        cell('', bg: _pLightBlue),
        cell('Total', bold: true, bg: _pLightBlue),
        cell('', bg: _pLightBlue),
        pw.Container(
          color: _pLightBlue,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: pw.Text(
            _fmtRupiah(grandTotal),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _pBlue,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: _pLightBlue, width: 0.5),
    columnWidths: const {
      0: pw.FixedColumnWidth(36),
      1: pw.FlexColumnWidth(),
      2: pw.FixedColumnWidth(110),
      3: pw.FixedColumnWidth(110),
    },
    children: [
      headerRow(),
      for (var i = 0; i < items.length; i++) itemRow(items[i], i.isOdd),
      totalRow(),
    ],
  );
}

pw.Widget _buildFooter() {
  return pw.Column(
    children: [
      pw.Center(
        child: pw.Text(
          'Thank you for your booking',
          style: pw.TextStyle(
            color: _pBlue,
            fontWeight: pw.FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Center(
        child: pw.Text(
          'Need help or have any issues?',
          style: pw.TextStyle(fontSize: 9, color: _pMuted),
        ),
      ),
      pw.Center(
        child: pw.Text(
          'Contact us at support@goin.com or +1234 567 890.',
          style: pw.TextStyle(fontSize: 9, color: _pMuted),
        ),
      ),
    ],
  );
}

// ─── Small helpers ───

pw.Widget _infoRow(String label, String value) {
  return pw.Row(
    children: [
      pw.SizedBox(
        width: 72,
        child: pw.Text(label, style: pw.TextStyle(fontSize: 11, color: _pDark)),
      ),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, color: _pDark)),
    ],
  );
}

pw.Widget _labelValueRow(String label, String value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
          color: _pDark,
        ),
      ),
      pw.Text(value, style: pw.TextStyle(fontSize: 11, color: _pDark)),
    ],
  );
}

// ─── Item model ───
class _ReceiptItem {
  const _ReceiptItem({
    required this.qty,
    required this.description,
    required this.unitPrice,
    required this.total,
  });
  final int qty;
  final String description;
  final double unitPrice;
  final double total;
}

List<_ReceiptItem> _buildItems(Booking booking) {
  if (booking.details.isEmpty) {
    return [
      _ReceiptItem(
        qty: 1,
        description: booking.roomType ?? 'Room',
        unitPrice: booking.totalPrice,
        total: booking.totalPrice,
      ),
    ];
  }

  final rows = <_ReceiptItem>[];
  for (final detail in booking.details) {
    final unitPrice = detail.totalRoom > 0
        ? detail.subTotal / detail.totalRoom
        : detail.subTotal;
    rows.add(
      _ReceiptItem(
        qty: detail.totalRoom,
        description: detail.roomType ?? booking.roomType ?? 'Room',
        unitPrice: unitPrice,
        total: detail.subTotal,
      ),
    );
    for (final addOn in detail.addOns) {
      final addOnUnit = addOn.quantity > 0
          ? addOn.subTotal / addOn.quantity
          : addOn.subTotal;
      rows.add(
        _ReceiptItem(
          qty: addOn.quantity,
          description: addOn.name,
          unitPrice: addOnUnit,
          total: addOn.subTotal,
        ),
      );
    }
  }
  return rows;
}

// ─── Formatters ───
String _fmtDate(String value) {
  final d = DateTime.tryParse(value);
  if (d == null) return value;
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

String _fmtDateTime(String value) {
  final d = DateTime.tryParse(value);
  if (d == null) return value;
  return '${_fmtDate(value)} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}';
}

String _fmtRupiah(double amount) {
  final value = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    if (i > 0 && (value.length - i) % 3 == 0) buffer.write('.');
    buffer.write(value[i]);
  }
  return 'Rp ${buffer.toString()},-';
}
