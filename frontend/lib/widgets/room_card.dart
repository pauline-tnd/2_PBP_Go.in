import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/pages/Detail_pages/detail_room_page.dart';

import '../models/room.dart';
import 'room_image.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final String? imageUrl;
  final VoidCallback? onSelectRoom;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> facilities;
  final List<String>? addOns;
  final List<Map<String, dynamic>> reviews;
  final String hotelName;
  final double reviewScore;

  const RoomCard({
    super.key,
    required this.room,
    this.imageUrl,
    this.onSelectRoom,
    this.imageUrls = const [],
    this.facilities = const [],
    this.addOns,
    this.reviews = const [],
    this.hotelName = 'Hotel',
    this.reviewScore = 0,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  void _openDetailRoomPage() {
    final imageUrls = widget.imageUrls.isNotEmpty
        ? widget.imageUrls
        : [if (widget.imageUrl != null) widget.imageUrl!];
    final addOns =
        widget.addOns ?? widget.room.addOns.map((addOn) => addOn.name).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRoomPage(
          room: widget.room,
          imageUrls: imageUrls,
          facilities: widget.facilities,
          addOns: addOns,
          reviews: widget.reviews,
          hotelName: widget.hotelName,
          reviewScore: widget.reviewScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final imageUrl = widget.imageUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoomImage(
            imagePath: imageUrl,
            placeholderColor: const Color(0xFF94A3B8),
            width: double.infinity,
            height: 180,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${room.roomSize} m²',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(room.price.toInt())}',
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity} Guest',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.bed_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room.type,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onSelectRoom ?? _openDetailRoomPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Select Room',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
