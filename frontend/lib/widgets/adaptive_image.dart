import 'package:flutter/material.dart';
import 'package:frontend/utils/image_path.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    final normalizedPath = normalizeImagePath(imagePath);
    if (normalizedPath.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isNetworkImagePath(normalizedPath)) {
      final resolvedUrl = normalizedPath.startsWith('//')
          ? 'https:$normalizedPath'
          : normalizedPath;
      return Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
      );
    }

    return Image.asset(
      normalizedPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
