import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/widgets/review/review_filter.dart';
import 'package:frontend/widgets/review/review_card.dart';

class ReviewDetailPage extends StatefulWidget {
  final List<Review> reviews;
  final String title;
  final bool showRoomFilter;
  final bool showRoomType;

  const ReviewDetailPage({
    super.key,
    required this.reviews,
    this.title = "Reviews",
    this.showRoomFilter = false,
    this.showRoomType = false,
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  String? _selectedImage;
  int? _filterRating; // null = show all
  String? _filterRoomType;

  List<String> get _roomTypes {
    final roomTypes = widget.reviews
        .map((review) => review.roomType)
        .whereType<String>()
        .where((roomType) => roomType.trim().isNotEmpty)
        .toSet()
        .toList();

    roomTypes.sort();
    return roomTypes;
  }

  List<Review> get _filteredReviews {
    return widget.reviews.where((review) {
      if (_filterRating != null && review.rating != _filterRating) {
        return false;
      }

      if (_filterRoomType != null && review.roomType != _filterRoomType) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                ReviewFilterBar(
                  showRoomFilter: widget.showRoomFilter,
                  roomTypes: _roomTypes,
                  selectedRoomType: _filterRoomType,
                  onRoomFilterChanged: (roomType) {
                    setState(() {
                      _filterRoomType = roomType;
                    });
                  },
                  onFilterChanged: (rating) {
                    setState(() {
                      _filterRating = rating;
                    });
                  },
                ),
                const SizedBox(height: 15),

                Expanded(
                  child: _filteredReviews.isEmpty
                      ? const Center(
                          child: Text(
                            "No reviews found for this rating",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredReviews.length,
                          itemBuilder: (_, i) {
                            return Column(
                              children: [
                                ReviewCard(
                                  review: _filteredReviews[i],
                                  onImageTap: _filteredReviews[i].image != null
                                      ? () => setState(
                                          () => _selectedImage =
                                              _filteredReviews[i].image,
                                        )
                                      : null,
                                  isExpanded: true,
                                  showRoomType: widget.showRoomType,
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          if (_selectedImage != null)
            GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                color: Colors.black54,
                child: Center(child: Image.network(_selectedImage!)),
              ),
            ),
        ],
      ),
    );
  }
}
