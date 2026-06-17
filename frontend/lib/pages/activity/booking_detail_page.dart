import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/pages/activity/receipt_download.dart' show showReceiptPreview;
import 'package:qr_flutter/qr_flutter.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.booking});

  static const Color _primary = Color(0xFF3B82F6);
  static const Color _text = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF94A3B8);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final details = booking.details;
    final totalNights = _totalNights;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _ReceiptAppBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _SuccessBadge()),
                    const SizedBox(height: 28),
                    Center(
                      child: QrImageView(
                        data: booking.bookingNumber,
                        version: QrVersions.auto,
                        size: 172,
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Booking Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.bookingNumber,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      _formatDateTime(booking.updatedAt),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DetailRow(
                      label: 'Check in',
                      value: _formatDate(booking.checkIn),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Check out',
                      value: _formatDate(booking.checkOut),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: 'Hotel',
                      value: booking.hotelName ?? 'Hotel',
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Room',
                      style: TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (details.isEmpty)
                      _RoomLine(
                        roomName: booking.roomType ?? 'Room',
                        quantity: 1,
                        subtotal: booking.totalPrice,
                      )
                    else
                      ...details.map(_buildRoomLine),
                    const Divider(height: 28, color: Color(0xFFE2E8F0)),
                    _DetailRow(label: 'Total nights', value: 'x$totalNights'),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: _text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _formatRupiah(booking.totalPrice),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => showReceiptPreview(context, booking),
                        icon: const Icon(
                          Icons.file_download_outlined,
                          size: 22,
                        ),
                        label: const Text(
                          'Download Receipt',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: _primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomLine(BookingDetailLine detail) {
    return _RoomLine(
      roomName: detail.roomType ?? booking.roomType ?? 'Room',
      quantity: detail.totalRoom,
      subtotal: detail.subTotal,
      notes: detail.notes,
      addOns: detail.addOns,
    );
  }

  int get _totalNights {
    final checkIn = DateTime.tryParse(booking.checkIn);
    final checkOut = DateTime.tryParse(booking.checkOut);
    if (checkIn == null || checkOut == null) return 0;
    final nights = checkOut.difference(checkIn).inDays;
    return nights < 0 ? 0 : nights;
  }

  static String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${_formatDate(value)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }

  static String _formatRupiah(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write('.');
      buffer.write(value[i]);
    }
    return 'Rp ${buffer.toString()},-';
  }
}

class _ReceiptAppBar extends StatelessWidget {
  const _ReceiptAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: AppBar(
        title: const Text("Receipt Details", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: onBack,
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BookingDetailPage._primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: BookingDetailPage._primary.withValues(alpha: 0.18),
            blurRadius: 0,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hotel booked successfully',
            style: TextStyle(
              color: BookingDetailPage._primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.check_circle_outline_rounded,
            color: BookingDetailPage._primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: BookingDetailPage._text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: BookingDetailPage._text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoomLine extends StatelessWidget {
  const _RoomLine({
    required this.roomName,
    required this.quantity,
    required this.subtotal,
    this.notes,
    this.addOns = const [],
  });

  final String roomName;
  final int quantity;
  final double subtotal;
  final String? notes;
  final List<BookingAddOnLine> addOns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${quantity}x $roomName',
                  style: const TextStyle(
                    color: BookingDetailPage._text,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                BookingDetailPage._formatRupiah(subtotal),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: BookingDetailPage._text,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ...addOns.map(
            (addOn) => Padding(
              padding: const EdgeInsets.only(top: 6, left: 32),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add on : ${addOn.name}',
                      style: const TextStyle(
                        color: BookingDetailPage._text,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    BookingDetailPage._formatRupiah(addOn.subTotal),
                    style: const TextStyle(
                      color: BookingDetailPage._text,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (notes != null && notes!.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, left: 32),
                child: Text(
                  'Notes : ${notes!.trim()}',
                  style: const TextStyle(
                    color: BookingDetailPage._muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
