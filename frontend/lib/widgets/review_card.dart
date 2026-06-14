import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/widgets/star_rating.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onImageTap;
  final bool isExpanded;

  const ReviewCard({
    super.key,
    required this.review,
    this.onImageTap,
    this.isExpanded = false,
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
            if (isExpanded)
              Text(
                review.description,
                maxLines: null,
                overflow: TextOverflow.visible,
              )
            else
              Expanded(
                child: Text(
                  review.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (review.image != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onImageTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    review.image!,
                    // ukuran gambar beda antara expanded dan tidak
                    width: isExpanded ? double.infinity : 90,
                    height: isExpanded ? 180 : 70,
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
