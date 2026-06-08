import 'package:flutter/material.dart';

class RoomImage extends StatefulWidget {
  final String? imagePath;
  final Color placeholderColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const RoomImage({
    super.key,
    this.imagePath,
    required this.placeholderColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<RoomImage> createState() => _RoomImageState();
}

class _RoomImageState extends State<RoomImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return _buildPlaceholder(borderRadius);
    }

    if (_hasError) {
      return _buildErrorFallback(borderRadius);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        widget.imagePath!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.width,
            height: widget.height,
            color: widget.placeholderColor,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          });
          return _buildErrorFallback(borderRadius);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BorderRadius borderRadius) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.placeholderColor,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.meeting_room_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: 40,
        ),
      ),
    );
  }

  // kl gambar gagal ngimport, tulis failed
  Widget _buildErrorFallback(BorderRadius borderRadius) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _hasError = false;
        });
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Failed to load',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Tap to reload',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
