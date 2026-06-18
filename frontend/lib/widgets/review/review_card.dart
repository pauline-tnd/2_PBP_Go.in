import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/widgets/review/star_rating.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onImageTap;
  final bool isExpanded;
  final bool showRoomType;

  const ReviewCard({
    super.key,
    required this.review,
    this.onImageTap,
    this.isExpanded = false,
    this.showRoomType = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.user?.profileImage != null
                      ? NetworkImage(review.user!.profileImage!)
                      : const AssetImage('assets/images/profile-photo.png')
                            as ImageProvider,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user?.username ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        review.createdAt != null
                            ? review.createdAt!.length >= 19
                                  ? '${review.createdAt!.substring(0, 10)}  ${review.createdAt!.substring(11, 19)}'
                                  : review.createdAt!
                            : 'Date not found',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // rating pindah ke bawah kalau expanded
                if (!isExpanded) StarRating(rating: review.rating),
              ],
            ),

            // rating di baris sendiri kalau expanded
            if (isExpanded) ...[
              const SizedBox(height: 6),
              StarRating(rating: review.rating),
            ],

            const SizedBox(height: 10),
            // Description review
            Text(
              review.description,
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (review.image != null && isExpanded) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onImageTap,
                child: SizedBox.square(
                  // width: 20,
                  dimension: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(review.image!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
            if (showRoomType && review.roomType != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    border: Border.all(color: const Color(0xFF3B82F6)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    review.roomType!,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
