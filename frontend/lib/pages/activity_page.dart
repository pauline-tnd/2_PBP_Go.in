import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/widgets/activity/activity_header.dart';
import 'package:frontend/widgets/activity/activity_card.dart';
import 'package:frontend/widgets/activity/activity_filter_dropdown.dart';
import 'package:frontend/pages/review_page.dart';
import 'package:frontend/utils/app_responsive.dart';

// ── Helpers (no locale-data initialization required) ─────────────
String _formatDate(String isoDate) {
  final d = DateTime.tryParse(isoDate);
  if (d == null) return isoDate;
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}

String _formatRupiah(double amount) {
  final s = amount.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp ${buf.toString()},-';
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  ActivityFilter _selectedFilter = ActivityFilter.all;
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.fetchBookings();
  }

  void _refresh() {
    setState(() {
      _bookingsFuture = ApiService.fetchBookings();
    });
  }

  /// Convert a [Booking] from the API to a [BookingItem] for the UI.
  BookingItem _toBookingItem(Booking b) {
    // ── Date formatting ───────────────────────────────────────────
    final dateStr = _formatDate(b.checkIn);

    // ── Price formatting (Indonesian Rupiah) ──────────────────────
    final priceStr = _formatRupiah(b.totalPrice);

    // ── Status mapping ────────────────────────────────────────────
    final BookingStatus status;
    switch (b.status.toLowerCase()) {
      case 'completed':
        status = BookingStatus.completed;
        break;
      case 'cancelled':
        status = BookingStatus.cancelled;
        break;
      default:
        status = BookingStatus.paid;
    }

    return BookingItem(
      id: b.id.toString(),
      date: dateStr,
      hotelName: b.hotelName ?? 'Hotel',
      roomType: b.roomType ?? 'Room',
      price: priceStr,
      status: status,
      imageUrl: b.roomImageUrl ?? '',
    );
  }

  /// Filter the already-fetched list based on the selected dropdown.
  List<BookingItem> _filterItems(List<BookingItem> items) {
    if (_selectedFilter == ActivityFilter.all) return items;
    return items.where((item) {
      switch (_selectedFilter) {
        case ActivityFilter.paid:
          return item.status == BookingStatus.paid;
        case ActivityFilter.completed:
          return item.status == BookingStatus.completed;
        case ActivityFilter.cancelled:
          return item.status == BookingStatus.cancelled;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppResponsive.horizontalPadding(context);
    final contentMaxWidth = AppResponsive.contentMaxWidth(
      context,
      mobile: 640,
      tablet: 860,
      desktop: 1080,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: ActivityHeader(
        body: FutureBuilder<List<Booking>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            // ── Loading ──────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
              );
            }

            // ── Error ────────────────────────────────────────────
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 80,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 56,
                        color: Color(0xFF9098A3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2340),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9098A3),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Coba lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── Success ──────────────────────────────────────────
            final allItems = (snapshot.data ?? []).map(_toBookingItem).toList();
            final filteredItems = _filterItems(allItems);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      0,
                    ),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown filter
                          ActivityFilterDropdown(
                            selected: _selectedFilter,
                            onChanged: (filter) {
                              setState(() => _selectedFilter = filter);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Booking cards
                          ...filteredItems.map(
                            (item) => ActivityCard(
                              item: item,
                              onBookingDetail: () {
                                // TODO: navigate to booking detail page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Detail booking: ${item.id}'),
                                  ),
                                );
                              },
                              // onReview: (rating) {
                              //   // TODO: send rating to backend
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(
                              //       content: Text(
                              //         'Rating diberikan: $rating bintang',
                              //       ),
                              //     ),
                              //   );
                              // },
                              onReview: (rating) async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewPage(
                                      bookingId: item.id,
                                    ),
                                  ),
                                );
                                _refresh();
                              },
                            ),
                          ),

                          // Empty state
                          if (filteredItems.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      allItems.isEmpty
                                          ? 'Belum ada booking'
                                          : 'Tidak ada booking dengan status ini',
                                      style: const TextStyle(
                                        color: Color(0xFF9098A3),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
