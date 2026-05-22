import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/widgets/room_image.dart';
import 'package:frontend/widgets/review_card.dart';
import 'package:frontend/widgets/add_on_pop_up.dart';

class DetailRoomPage extends StatefulWidget {
  final Room room;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> facilities;
  final List<String> addOns;
  final List<Map<String, dynamic>> reviews;
  final String hotelName;
  final double reviewScore;

  const DetailRoomPage({
    super.key,
    required this.room,
    required this.imageUrls,
    required this.facilities,
    required this.addOns,
    required this.reviews,
    required this.hotelName,
    required this.reviewScore,
  });

  @override
  State<DetailRoomPage> createState() => _DetailRoomPageState();
}

class _DetailRoomPageState extends State<DetailRoomPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final priceFormatted = NumberFormat(
      '#,###',
      'id_ID',
    ).format(room.price.toInt());

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF1E293B),
                  size: 24,
                ),
              ),
            ),
            title: const Text(
              'Room Detail',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 240,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.isEmpty
                            ? 1
                            : widget.imageUrls.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          final url = widget.imageUrls.isEmpty
                              ? null
                              : widget.imageUrls[index];
                          return RoomImage(
                            imagePath: url,
                            placeholderColor: const Color(0xFF94A3B8),
                            width: double.infinity,
                            height: 240,
                            borderRadius: BorderRadius.zero,
                          );
                        },
                      ),
                      if (widget.imageUrls.length > 1) ...[
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CarouselButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () {
                                if (_currentImageIndex > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CarouselButton(
                              icon: Icons.chevron_right_rounded,
                              onTap: () {
                                if (_currentImageIndex <
                                    widget.imageUrls.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.imageUrls.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: i == _currentImageIndex ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _currentImageIndex
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.hotelName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp $priceFormatted',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              const Text(
                                '/night',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        room.type,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        room.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.person_outline_rounded,
                            label: 'CAPACITY',
                            value: '${room.capacity} Guest',
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.straighten_rounded,
                            label: 'SIZE',
                            value: '${room.roomSize} m\u00B2',
                          ),
                          const SizedBox(width: 8),
                          const _InfoChip(
                            icon: Icons.bed_outlined,
                            label: 'BED TYPE',
                            value: '1 King',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Main Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.facilities
                          .take(5)
                          .map(
                            (f) => _FacilityRow(
                              icon: f['icon'] as IconData,
                              name: f['name'] as String,
                            ),
                          ),
                      const SizedBox(height: 20),

                      const Text(
                        'Room Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      // ...[
                      //   'Television',
                      //   'Desk',
                      //   'In-room Safe',
                      //   'Hair Dryer',
                      // ].map(
                      //   (item) => Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 3),
                      //     child: Row(
                      //       children: [
                      //         const Text(
                      //           '• ',
                      //           style: TextStyle(color: Color(0xFF64748B)),
                      //         ),
                      //         Text(
                      //           item,
                      //           style: const TextStyle(
                      //             fontSize: 13,
                      //             color: Color(0xFF64748B),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 24),

                      const Text(
                        'Add On',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.addOns.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                              Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Text(
                            "Room's review",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.reviewScore} / 5',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: const [
                                Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      final Map<String, dynamic> review;
                      const _ReviewCard({required this.review});

                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.reviews.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              ReviewCard(review: widget.reviews[index]),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddOnPopUp(
                    roomType: widget.room.type,
                    addOns: widget.room.addOns,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CarouselButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityRow extends StatelessWidget {
  final IconData icon;
  final String name;
  const _FacilityRow({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}
