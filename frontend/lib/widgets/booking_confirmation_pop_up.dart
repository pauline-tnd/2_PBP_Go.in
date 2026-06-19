import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/bookingDetail.dart';
import 'package:frontend/models/addOn.dart';
import 'package:frontend/widgets/room/add_on_pop_up.dart';
import 'package:frontend/widgets/adaptive_image.dart';
import 'package:frontend/services/api_services.dart';

class BookingConfirmationPopUp extends StatefulWidget {
  final List<BookingDetail> bookingDetails;
  final List<AddOnItem> allAddOns;
  final String hotelName;
  final String hotelLocation;
  final String previewImageUrl;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final void Function()? onCustomAnother;
  final void Function(List<BookingDetail> bookingDetails, int bookingId)?
  onBookNow;
  final void Function(int index)? onEditItem;
  final void Function(int index)? onDeleteItem;
  final void Function()? onNavigateToHotel;
  final void Function(List<BookingDetail>)? onBookingListChanged;

  const BookingConfirmationPopUp({
    super.key,
    required this.bookingDetails,
    required this.allAddOns,
    this.hotelName = 'Hotel',
    this.hotelLocation = '',
    this.previewImageUrl = '',
    this.checkIn,
    this.checkOut,
    this.onCustomAnother,
    this.onBookNow,
    this.onEditItem,
    this.onDeleteItem,
    this.onNavigateToHotel,
    this.onBookingListChanged,
  });

  @override
  State<BookingConfirmationPopUp> createState() =>
      _BookingConfirmationPopUpState();
}

class _BookingConfirmationPopUpState extends State<BookingConfirmationPopUp> {
  static const _blue = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1E293B);
  static const _muted = Color(0xFF94A3B8);
  static const _line = Color(0xFFE2E8F0);

  bool _isBookingNow = false;

  static String _formatDate(DateTime v) =>
      '${v.year.toString().padLeft(4, '0')}-'
      '${v.month.toString().padLeft(2, '0')}-'
      '${v.day.toString().padLeft(2, '0')}';

  Future<void> _handleBookNow() async {
    if (_isBookingNow) return;
    final checkIn = widget.checkIn;
    final checkOut = widget.checkOut;
    if (checkIn == null || checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates first')),
      );
      return;
    }
    setState(() => _isBookingNow = true);
    try {
      final bookingResp = await ApiService.storeBooking(
        checkIn: _formatDate(checkIn),
        checkOut: _formatDate(checkOut),
        status: 'pending',
      );
      final bookingId = int.tryParse(
        (bookingResp['booking'] as Map<String, dynamic>?)?['id']?.toString() ??
            '',
      );
      if (bookingId == null) throw Exception('Booking ID not returned.');

      for (final detail in widget.bookingDetails) {
        final detailResp = await ApiService.storeBookingDetail(
          bookingId: bookingId,
          roomId: detail.room.id,
          totalRoom: detail.quantity,
          notes: detail.notes.isEmpty ? null : detail.notes,
        );
        final bookingDetailId = int.tryParse(
          (detailResp['detail'] as Map<String, dynamic>?)?['id']?.toString() ??
              '',
        );
        if (bookingDetailId == null)
          throw Exception('Booking detail ID not returned.');

        for (final addOn in detail.selectedAddOns) {
          if (addOn.id <= 0) continue;
          await ApiService.storeBookingDetailAddOn(
            bookingDetailId: bookingDetailId,
            addOnId: addOn.id,
            qty: detail.quantity,
            subTotal: addOn.price * detail.quantity,
          );
        }
      }

      if (!mounted) return;
      widget.onBookNow?.call(List.from(widget.bookingDetails), bookingId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBookingNow = false);
    }
  }

  String formatPrice(double price) {
    return NumberFormat('#,###', 'en_US').format(price.toInt());
  }

  double itemTotal(BookingDetail detail) {
    final addOnsTotal = detail.selectedAddOns.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );

    return (detail.room.price + addOnsTotal) * detail.quantity;
  }

  double grandTotal() {
    return widget.bookingDetails.fold<double>(
      0,
      (sum, detail) => sum + itemTotal(detail),
    );
  }

  String _addOnsText(BookingDetail detail) {
    if (detail.selectedAddOns.isEmpty) return '-';
    return detail.selectedAddOns.map((item) => item.name).join(', ');
  }

  Widget _roomImage(String imageUrl, double size) {
    final placeholder = Container(
      width: size,
      height: size,
      color: const Color(0xFFE2E8F0),
      child: const Icon(
        Icons.meeting_room_rounded,
        color: Color(0xFF94A3B8),
        size: 34,
      ),
    );

    if (imageUrl.isEmpty) return placeholder;

    return AdaptiveImage(
      imagePath: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }

  Widget _bookingItem(BookingDetail detail, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final imageSize = compact ? 90.0 : 108.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _roomImage(detail.roomImage, imageSize),
            ),
            SizedBox(width: compact ? 14 : 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          detail.room.type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      _IconAction(
                        icon: Icons.edit_outlined,
                        onPressed: () => _showEditPopUp(context, detail, index),
                      ),
                      _IconAction(
                        icon: Icons.delete_outline,
                        onPressed: () => _showDeleteConfirmation(index),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                if (detail.quantity > 1) {
                                  setState(() {
                                    detail.quantity--;
                                  });
                                  widget.onBookingListChanged?.call(
                                    List.from(widget.bookingDetails),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.remove, size: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                detail.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  detail.quantity++;
                                });
                                widget.onBookingListChanged?.call(
                                  List.from(widget.bookingDetails),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.add, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add-on : ${_addOnsText(detail)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: _dark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail.notes.isEmpty
                        ? 'Notes : -'
                        : 'Notes : ${detail.notes}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _muted),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Rp ${formatPrice(itemTotal(detail))}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditPopUp(BuildContext context, BookingDetail detail, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddOnPopUp(
        roomType: detail.room.type,
        addOns: widget.allAddOns,
        room: detail.room,
        roomImage: detail.roomImage,
        initialNotes: detail.notes,
        existingBookings: widget.bookingDetails,
        editIndex: index,
        onContinue: (selected, notes) async {
          if (mounted) {
            setState(() {
              detail.selectedAddOns = selected;
              detail.notes = notes;
            });
            widget.onBookingListChanged?.call(List.from(widget.bookingDetails));
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        content: const Text(
          'Remove from booking?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'No',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 29, 44, 68),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);

              setState(() {
                widget.bookingDetails.removeAt(index);
              });
              widget.onDeleteItem?.call(index);
              widget.onBookingListChanged?.call(
                List.from(widget.bookingDetails),
              );
              if (widget.bookingDetails.isEmpty) Navigator.pop(context);
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(155, 29, 44, 68),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenHeight = screenSize.height;
    final sw = screenSize.width;
    final hPad = (sw * 0.072).clamp(20.0, 32.0);
    final btnGap = (sw * 0.031).clamp(8.0, 16.0);
    final btnVGap = (sw * 0.041).clamp(12.0, 20.0);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18),
            Container(
              width: 58,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF94A3B8),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Flexible(
              child: widget.bookingDetails.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 64,
                      ),
                      child: Center(
                        child: Text(
                          'No rooms selected',
                          style: TextStyle(fontSize: 16, color: _muted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(28, 64, 28, 36),
                      itemCount: widget.bookingDetails.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 30),
                      itemBuilder: (context, index) =>
                          _bookingItem(widget.bookingDetails[index], index),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: _line),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 15, color: _muted),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp ${formatPrice(grandTotal())}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: _blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'Price includes tax',
                          style: TextStyle(fontSize: 13, color: _muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _line),
                  SizedBox(height: btnVGap),
                  Row(
                    children: [
                      Expanded(
                        child: _BottomActionButton(
                          label: 'Custom Another',
                          onPressed: widget.onCustomAnother,
                          outlined: true,
                        ),
                      ),
                      SizedBox(width: btnGap),
                      Expanded(
                        child: _BottomActionButton(
                          label: 'Book Now',
                          onPressed: (_isBookingNow || widget.onBookNow == null)
                              ? null
                              : _handleBookNow,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: btnVGap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _IconAction({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(icon, color: const Color(0xFFBFC3C9), size: 28),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  const _BottomActionButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final btnH = (sw * 0.123).clamp(40.0, 58.0);
    final fs = (sw * 0.038).clamp(13.0, 18.0);
    final radius = btnH / 2;

    final child = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w500,
          color: outlined ? const Color(0xFF3B82F6) : Colors.white,
        ),
      ),
    );

    if (outlined) {
      return SizedBox(
        height: btnH,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF3B82F6),
            elevation: 5,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: btnH,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      ),
    );
  }
}
