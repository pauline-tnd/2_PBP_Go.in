import 'package:flutter/material.dart';
import 'package:frontend/widgets/hotel_image.dart';

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
    setState(() => _animatingFrom = _current);
    _animController.forward(from: 0).then((_) {
      setState(() {
        _current = index;
        _animatingFrom = null;
      });
    });
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

    final screenW = MediaQuery.of(context).size.width;
    final centerW = screenW * 0.60;
    final sideW = screenW * 0.38;
    final centerH = widget.height;
    final sideH = widget.height * 0.78;

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
        height: centerH + 12,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (_leftIndex != null)
              Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _goTo(_leftIndex!),
                  child: Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..translate(-8.0, 0.0)
                      ..rotateZ(-0.08),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: sideW,
                        height: sideH,
                        child: HotelImage(
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
              ),

            if (_rightIndex != null && _rightIndex != _leftIndex)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _goTo(_rightIndex!),
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..translate(8.0, 0.0)
                      ..rotateZ(0.08),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: sideW,
                        height: sideH,
                        child: HotelImage(
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
                  child: HotelImage(
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
