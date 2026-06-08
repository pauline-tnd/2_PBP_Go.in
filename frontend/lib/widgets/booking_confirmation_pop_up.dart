import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/addOn.dart';
import 'package:frontend/models/room.dart';

class BookingConfirmationPopUp extends StatefulWidget {
  final Room room;
  final String roomImage;
  final List<AddOnItem> selectedAddOns;
  final String notes;
  final int quantity;
  final void Function()? onCustomAnother;
  final void Function()? onBookNow;

  const BookingConfirmationPopUp({
    super.key,
    required this.room,
    required this.roomImage,
    required this.selectedAddOns,
    required this.notes,
    this.quantity = 1,
    this.onCustomAnother,
    this.onBookNow,
  });

  @override
  State<BookingConfirmationPopUp> createState() =>
      _BookingConfirmationPopUpState();
}

class _BookingConfirmationPopUpState extends State<BookingConfirmationPopUp> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
  }

  String _formatPrice(double price) {
    return NumberFormat(
      '#,###',
      'id_ID',
    ).format(price.toInt()).replaceAll(',', '.');
  }

  double _calculateAddOnsTotal() {
    return widget.selectedAddOns.fold(0, (sum, addon) => sum + addon.price);
  }

  double _calculateSubtotal() {
    final roomTotal = widget.room.price * _quantity;
    final addOnsTotal = _calculateAddOnsTotal() * _quantity;
    return roomTotal + addOnsTotal;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final addOnsText = widget.selectedAddOns.isEmpty
        ? '–'
        : widget.selectedAddOns.map((e) => e.name).join(', ');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Card
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 140,
                            color: const Color(0xFF94A3B8),
                            child: widget.roomImage.isNotEmpty
                                ? Image.network(
                                    widget.roomImage,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.room.type,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Add-on : $addOnsText',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    if (widget.notes.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Notes : ${widget.notes}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // Edit functionality will be added later
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          // Delete functionality will be added later
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rp ${_formatPrice(widget.room.price)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quantity Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: _quantity > 1
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Divider(
                    color: const Color(0xFFE2E8F0),
                    thickness: 1,
                    height: 1,
                  ),

                  const SizedBox(height: 16),

                  // Subtotal Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(subtotal)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Price includes tax',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onCustomAnother?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Custom Another',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onBookNow?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
