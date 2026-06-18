import 'dart:async';
import 'package:flutter/material.dart';

class _FallbackImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _FallbackImage({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  static const _fallbacks = [
    'assets/images/RoomDefault/hotel_room_1.png',
    'assets/images/RoomDefault/hotel_room_2.png',
    'assets/images/RoomDefault/hotel_room_3.png',
  ];

  bool get _isAsset => imagePath.startsWith('assets/');

  Widget _fallback(double w, double h) =>
      Image.asset(_fallbacks[0], width: w, height: h, fit: BoxFit.cover);

  @override
  Widget build(BuildContext context) {
    if (_isAsset) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(width, height),
    );
  }
}

class Carousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const Carousel({super.key, required this.imageUrls, this.height = 220});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _current = 0;
  Timer? _autoPlayTimer;

  List<String> get _images => widget.imageUrls;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_images.isNotEmpty) {
        _goTo((_current + 1) % _images.length, direction: 1);
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _goTo(int index, {int direction = 1}) {
    if (index == _current || index < 0 || index >= _images.length) return;
    setState(() => _current = index);
  }

  int? get _leftIndex {
    if (_images.length < 2) return null;
    return (_current - 1 + _images.length) % _images.length;
  }

  int? get _rightIndex {
    if (_images.length < 2) return null;
    return (_current + 1) % _images.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availW = constraints.maxWidth;
        final scale = (availW / 400).clamp(0.65, 1.15);
        final centerH = widget.height * scale;
        final centerW = (availW * 0.58).clamp(160.0, centerH * 1.4);
        final sideH = centerH * 0.70;
        final sideW = centerW * 0.68;
        final centerX = (availW - centerW) / 2;
        final gap = availW * 0.30;
        final leftX = (availW / 2 - gap - sideW / 2).clamp(0.0, availW - sideW);
        final rightX = (availW / 2 + gap - sideW / 2).clamp(
          0.0,
          availW - sideW,
        );
        const duration = Duration(milliseconds: 350);

        final List<Widget> boxes = [];
        final renderOrder = [
          _leftIndex,
          _rightIndex,
          _current,
        ].whereType<int>().toList();

        for (final i in renderOrder) {
          final isCenter = i == _current;
          final isLeft = i == _leftIndex;
          final isRight = i == _rightIndex;

          final double targetX = isCenter
              ? centerX
              : isLeft
              ? leftX
              : rightX;
          final double targetTop = isCenter ? 0 : (centerH - sideH) / 2;
          final double targetW = isCenter ? centerW : sideW;
          final double targetH = isCenter ? centerH : sideH;
          final double radius = isCenter ? 22 : 20;

          final int capturedIndex = i;
          final bool capturedIsLeft = isLeft;
          final bool capturedIsRight = isRight;
          final int? capturedRightIndex = _rightIndex;

          boxes.add(
            AnimatedPositioned(
              key: ValueKey(capturedIndex),
              duration: duration,
              curve: Curves.easeInOut,
              left: targetX,
              top: targetTop,
              width: targetW,
              height: targetH,
              child: GestureDetector(
                onTap: () {
                  if (capturedIsLeft) _goTo(capturedIndex, direction: -1);
                  if (capturedIsRight) _goTo(capturedIndex, direction: 1);
                  if (!capturedIsLeft && !capturedIsRight)
                    _goTo(capturedRightIndex ?? 0, direction: 1);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: _FallbackImage(
                    imagePath: _images[capturedIndex],
                    width: targetW,
                    height: targetH,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: centerH + 20,
          child: Stack(clipBehavior: Clip.hardEdge, children: boxes),
        );
      },
    );
  }
}
