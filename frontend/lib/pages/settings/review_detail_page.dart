import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isActive: _filterRating == null,
                  onTap: () => setState(() => _filterRating = null),
                ),
                ...List.generate(5, (i) {
                  final star = 5 - i;
                  return _FilterChip(
                    label: '${'★' * star} $star',
                    isActive: _filterRating == star,
                    onTap: () => setState(() => _filterRating = star),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filteredReviews.length,
              itemBuilder: (_, i) => ReviewCard(
                review: _filteredReviews[i],
                onImageTap: _filteredReviews[i].image != null
                    ? () => setState(
                        () => _selectedImage = _filteredReviews[i].image,
                      )
                    : null,
              ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
