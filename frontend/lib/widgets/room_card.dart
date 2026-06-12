import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/pages/Detail_pages/detail_room_page.dart';
import 'package:frontend/models/addOn.dart';
import 'package:frontend/models/facilityIcons.dart';
import 'package:frontend/models/bookingDetail.dart' as details;
import 'package:frontend/models/room.dart';
import 'package:frontend/widgets/room_image.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final String? imageUrl;
  final VoidCallback? onSelectRoom;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> facilities;
  final List<AddOnItem>? addOns;
  final List<Map<String, dynamic>> reviews;
  final String hotelName;
  final double reviewScore;
  final List<details.BookingDetail> tempBookedList;
  final void Function(List<details.BookingDetail>)? onNavigatedBack;

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
    this.tempBookedList = const [],
    this.onNavigatedBack,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  Future<void> _openDetailRoomPage() async {
    final imageUrls = widget.room.roomImages.isNotEmpty
        ? widget.room.roomImages
        : widget.imageUrls.isNotEmpty
        ? widget.imageUrls
        : [if (widget.imageUrl != null) widget.imageUrl!];
    final addOns = widget.addOns ?? widget.room.addOns;

    final result = await Navigator.push<List<details.BookingDetail>>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRoomPage(
          room: widget.room,
          imageUrls: imageUrls,
          facilities: widget.facilities,
          roomAmenities: widget.room.roomFacilities,
          addOns: addOns,
          reviews: widget.reviews,
          hotelName: widget.hotelName,
          reviewScore: widget.reviewScore,

          tempBookedList: widget.tempBookedList,
        ),
      ),
    );

    if (result != null) {
      widget.onNavigatedBack?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    final images = room.roomImages.isNotEmpty
        ? room.roomImages
        : widget.imageUrls.isNotEmpty
        ? widget.imageUrls
        : [if (widget.imageUrl != null) widget.imageUrl!];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: images.isEmpty
                ? Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFF94A3B8),
                    child: Icon(
                      Icons.meeting_room_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 48,
                    ),
                  )
                : RoomImage(
                    imagePath: images.first,
                    placeholderColor: const Color(0xFF94A3B8),
                    width: double.infinity,
                    height: 200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.type,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${room.roomSize} m²',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(room.price.toInt())}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const Text(
                          '/night',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

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
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.bed_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        '1 ${room.type} bed',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onSelectRoom ?? _openDetailRoomPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
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
