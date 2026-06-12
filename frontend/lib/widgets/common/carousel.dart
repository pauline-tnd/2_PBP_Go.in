import 'package:flutter/material.dart';
import 'package:frontend/widgets/room_image.dart';

class Carousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const Carousel({super.key, required this.imageUrls, this.height = 220});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late AnimationController _animController;
  late Animation<double> _anim;
  int? _animatingFrom;

  List<String> get _images => widget.imageUrls;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index == _current || index < 0 || index >= _images.length) return;

    setState(() {
      _current = index;
    });
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

    final screenW = MediaQuery.of(context).size.width;
    final centerH = 150.0;
    final centerW = 220.0;
    final sideH = 105.0;
    final sideW = 150.0;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200) {
          _goTo((_current + 1) % _images.length);
        } else if (details.primaryVelocity! > 200) {
          _goTo((_current - 1 + _images.length) % _images.length);
        }
      },
      child: SizedBox(
        height: centerH + 20,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            if (_leftIndex != null)
              Positioned(
                left: (screenW - centerW) / 2 - sideW + 60,
                top: (centerH - sideH) / 2,
                child: GestureDetector(
                  onTap: () => _goTo(_leftIndex!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: sideW,
                      height: sideH,
                      child: RoomImage(
                        imagePath: _images[_leftIndex!],
                        placeholderColor: const Color(0xFF1E3A5F),
                        width: sideW,
                        height: sideH,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),

            if (_rightIndex != null && _rightIndex != _leftIndex)
              Positioned(
                right: (screenW - centerW) / 2 - sideW + 60,
                top: (centerH - sideH) / 2,
                child: GestureDetector(
                  onTap: () => _goTo(_rightIndex!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: sideW,
                      height: sideH,
                      child: RoomImage(
                        imagePath: _images[_rightIndex!],
                        placeholderColor: const Color(0xFF1E3A5F),
                        width: sideW,
                        height: sideH,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              top: 0,
              left: (screenW - centerW) / 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                width: centerW,
                height: centerH,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: RoomImage(
                    imagePath: _images[_current],
                    placeholderColor: const Color(0xFF1E3A5F),
                    width: centerW,
                    height: centerH,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
