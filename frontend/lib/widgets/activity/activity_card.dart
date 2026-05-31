import 'package:flutter/material.dart';

enum BookingStatus { paid, completed, cancelled }

class BookingItem {
  final String id;
  final String date;
  final String hotelName;
  final String roomType;
  final String price;
  final BookingStatus status;
  final String imageUrl;
  final int? reviewRating;
  final bool hasReview;

  const BookingItem({
    required this.id,
    required this.date,
    required this.hotelName,
    required this.roomType,
    required this.price,
    required this.status,
    required this.imageUrl,
    this.reviewRating,
    this.hasReview = false,
  });
}

class ActivityCard extends StatelessWidget {
  final BookingItem item;
  final VoidCallback? onBookingDetail;
  final ValueChanged<int>? onReview; // only for completed

  const ActivityCard({
    super.key,
    required this.item,
    this.onBookingDetail,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 12),

            // Hotel Info Row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hotel, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.hotelName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.roomType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Price
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.price,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Actions
            Row(
              mainAxisAlignment: item.status != BookingStatus.completed
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (item.status == BookingStatus.completed) ...[
                  Expanded(
                    child: _ReviewButton(
                      onRate: onReview,
                      initialRating: item.reviewRating ?? 0,
                      hasReview: item.hasReview,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                _BookingDetailButton(
                  onTap: onBookingDetail,
                  isDisabled: item.status == BookingStatus.cancelled,
                ),
                // Expanded(child: _BookingDetailButton(onTap: onBookingDetail)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(BookingStatus status) {
    switch (status) {
      case BookingStatus.paid:
        return _StatusConfig(
          label: 'Paid',
          backgroundColor: const Color(0xFFFF9800),
          textColor: Colors.white,
        );
      case BookingStatus.completed:
        return _StatusConfig(
          label: 'Completed',
          backgroundColor: const Color(0xFF4CAF50),
          textColor: Colors.white,
        );
      case BookingStatus.cancelled:
        return _StatusConfig(
          label: 'Cancelled',
          backgroundColor: const Color(0xFFE53935),
          textColor: const Color(0xFFFFEBEE),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

class _ReviewButton extends StatefulWidget {
  final ValueChanged<int>? onRate;
  final int initialRating;
  final bool hasReview;

  const _ReviewButton({
    this.onRate,
    this.initialRating = 0,
    this.hasReview = false,
  });

  @override
  State<_ReviewButton> createState() => _ReviewButtonState();
}

class _ReviewButtonState extends State<_ReviewButton> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E4EA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            widget.hasReview ? 'Reviewed' : 'Review',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 6),

          ...List.generate(5, (i) {
            return GestureDetector(
              onTap: () {
                widget.onRate?.call(i + 1);

                if (!widget.hasReview) {
                  setState(() => _rating = i + 1);
                }
              },
              child: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                size: 17,
                color: i < _rating
                    ? const Color(0xFFFFC107)
                    : const Color(0xFFBDBDBD),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BookingDetailButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isDisabled;

  const _BookingDetailButton({this.onTap, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Color(0XFF94A3B8),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Booking Detail',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
