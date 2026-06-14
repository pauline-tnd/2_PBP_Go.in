import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/widgets/star_rating.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onImageTap;

  const ReviewCard({super.key, required this.review, this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.user?.profileImage != null
                      ? NetworkImage(review.user!.profileImage!)
                      : const AssetImage('assets/profile-photo.png')
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
                                  ? review.createdAt!.substring(0, 10) +
                                        '  ' +
                                        review.createdAt!.substring(11, 19)
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
                StarRating(rating: review.rating),
              ],
            ),
            const SizedBox(height: 10),
            // Description review
            Text(
              review.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (review.image != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onImageTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    review.image!,
                    width: 90,
                    height: 70,
                    fit: BoxFit.cover,
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
