import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/widgets/review/review_filter.dart';
import 'package:frontend/widgets/review_card.dart';

class ReviewDetailPage extends StatefulWidget {
  final List<Review> reviews;

  const ReviewDetailPage({super.key, required this.reviews});

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  String? _selectedImage;
  int? _filterRating; // null = show all

  List<Review> get _filteredReviews {
    if (_filterRating == null) return widget.reviews;
    return widget.reviews
        .where((review) => review.rating == _filterRating)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Room's Review"), centerTitle: true),
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ReviewFilterBar(
                      onFilterChanged: (rating) {
                        setState(() {
                          _filterRating = rating;
                        });
                      },
                    ),
                  ],
                ),
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
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
              ),
            ],
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
