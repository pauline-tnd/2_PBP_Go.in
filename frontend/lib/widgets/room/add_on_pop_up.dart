import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/addOn.dart';
// import 'package:frontend/widgets/booking_confirmation_pop_up.dart';
import 'package:frontend/models/bookingDetail.dart';

class AddOnPopUp extends StatefulWidget {
  final String roomType;
  final List<AddOnItem> addOns;
  final Room room;
  final String roomImage;
  final String initialNotes;
  final Future<void> Function(List<AddOnItem> selected, String notes)?
  onContinue;
  final List<BookingDetail>? existingBookings;
  final int? editIndex;
  final void Function(List<BookingDetail>, int bookingId)?
  onConfirmationCustomAnother;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final int? existingBookingId;

  const AddOnPopUp({
    super.key,
    required this.roomType,
    required this.addOns,
    required this.room,
    required this.roomImage,
    this.initialNotes = '',
    this.onContinue,
    this.existingBookings,
    this.editIndex,
    this.onConfirmationCustomAnother,
    this.checkIn,
    this.checkOut,
    this.status = 'paid',
    this.existingBookingId,
  });

  @override
  State<AddOnPopUp> createState() => _AddOnPopUpState();
}

class _AddOnPopUpState extends State<AddOnPopUp> {
  final Set<int> _selectedIndexes = {};
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.initialNotes;

    if (widget.editIndex != null && widget.existingBookings != null) {
      final existing = widget.existingBookings![widget.editIndex!];
      _notesController.text = existing.notes;
      for (int i = 0; i < widget.addOns.length; i++) {
        if (existing.selectedAddOns.any((a) => a.id == widget.addOns[i].id)) {
          _selectedIndexes.add(i);
        }
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final selected = _selectedIndexes.map((i) => widget.addOns[i]).toList();
    final notes = _notesController.text;

    try {
      if (widget.onContinue != null) {
        await widget.onContinue!(selected, notes);
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }

      final checkIn = widget.checkIn;
      final checkOut = widget.checkOut;

      if (checkIn == null || checkOut == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please Pick Date First')));
        return;
      }

      final newDetail = BookingDetail(
        id: 0,
        room: widget.room,
        quantity: 1,
        roomImage: widget.roomImage,
        notes: notes,
        selectedAddOns: selected,
      );

      final List<BookingDetail> allDetails = List.from(
        widget.existingBookings ?? <BookingDetail>[],
      );
      allDetails.add(newDetail);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onConfirmationCustomAnother?.call(allDetails, 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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

          Text(
            widget.roomType,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 20),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add On',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...List.generate(widget.addOns.length, (index) {
                    final item = widget.addOns[index];
                    final selected = _selectedIndexes.contains(index);
                    final priceFormatted = NumberFormat(
                      '#,###',
                      'id_ID',
                    ).format(item.price.toInt()).replaceAll(',', '.');

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedIndexes.remove(index);
                          } else {
                            _selectedIndexes.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF3B82F6)
                                    : Colors.white,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            Icon(
                              item.icon,
                              size: 22,
                              color: const Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),

                            Text(
                              'Rp $priceFormatted',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _notesController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleContinue(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Please add more tea box...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFCBD5E1),
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFFCBD5E1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF93C5FD),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
