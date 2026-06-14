import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/bookingDetail.dart';
import 'package:frontend/models/addOn.dart';
import 'package:frontend/widgets/add_on_pop_up.dart';
import 'package:frontend/widgets/adaptive_image.dart';

class BookingConfirmationPopUp extends StatefulWidget {
  final List<BookingDetail> bookingDetails;
  final List<AddOnItem> allAddOns;
  final String hotelName;
  final String hotelLocation;
  final String previewImageUrl;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final void Function()? onCustomAnother;
  final void Function(List<BookingDetail> bookingDetails)? onBookNow;
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
        final imageSize = compact ? 88.0 : 108.0;
        final titleSize = compact ? 22.0 : 25.0;
        final priceSize = compact ? 24.0 : 28.0;

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
                            fontSize: titleSize,
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
                        onPressed: () =>
                            _showDeleteConfirmation(context, index),
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
                              onTap: () {
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
                              onTap: () {
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
                  const SizedBox(height: 4),
                  Text(
                    'Add-on : ${_addOnsText(detail)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: _dark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    detail.notes.isEmpty
                        ? 'Notes : -'
                        : 'Notes : ${detail.notes}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: _muted),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Rp ${formatPrice(itemTotal(detail))}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: priceSize,
                        fontWeight: FontWeight.w500,
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
        onConfirmationCustomAnother: (updatedList) {
          setState(() {
            widget.bookingDetails
              ..clear()
              ..addAll(updatedList);
          });
          widget.onBookingListChanged?.call(List.from(widget.bookingDetails));
        },
        onContinue: (selected, notes) {
          setState(() {
            detail.selectedAddOns.clear();
            detail.selectedAddOns.addAll(selected);
            detail.notes = notes;
          });
          widget.onBookingListChanged?.call(List.from(widget.bookingDetails));
          Future.delayed(Duration.zero, () {
            setState(() {});
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
              setState(() {
                widget.bookingDetails.removeAt(index);
              });

              widget.onDeleteItem?.call(index);

              widget.onBookingListChanged?.call(
                List.from(widget.bookingDetails),
              );

              if (widget.bookingDetails.isEmpty) {
                Navigator.pop(context);
              }
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
    final screenHeight = MediaQuery.sizeOf(context).height;
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
                      separatorBuilder: (_, _) => const SizedBox(height: 42),
                      itemBuilder: (context, index) =>
                          _bookingItem(widget.bookingDetails[index], index),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: _line),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 22, color: _muted),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Rp ${formatPrice(grandTotal())}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: _blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'Price includes tax',
                          style: TextStyle(fontSize: 16, color: _muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Divider(height: 1, color: _line),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: _BottomActionButton(
                          label: 'Custom Another',
                          onPressed: widget.onCustomAnother,
                          outlined: true,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _BottomActionButton(
                          label: 'Book Now',
                          onPressed: widget.onBookNow == null
                              ? null
                              : () => widget.onBookNow!(
                                  List.from(widget.bookingDetails),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
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
    final child = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: outlined ? const Color(0xFF3B82F6) : Colors.white,
        ),
      ),
    );

    if (outlined) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: child,
      ),
    );
  }
}
