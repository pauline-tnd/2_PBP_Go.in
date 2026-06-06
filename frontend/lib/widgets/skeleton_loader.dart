import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.4 + (_controller.value * 2.8), -0.3),
              end: Alignment(-0.4 + (_controller.value * 2.8), 0.3),
              colors: const [
                Color(0xFFE7EEF8),
                Color(0xFFF8FBFF),
                Color(0xFFE7EEF8),
              ],
              stops: const [0.1, 0.45, 0.9],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEF8),
        borderRadius: borderRadius,
      ),
    );
  }
}

class HotelCardSkeleton extends StatelessWidget {
  const HotelCardSkeleton({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SkeletonLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(
              width: double.infinity,
              height: 160,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: SkeletonBox(height: 18)),
                      SizedBox(width: 12),
                      SkeletonBox(width: 68, height: 16),
                    ],
                  ),
                  SizedBox(height: 8),
                  SkeletonBox(width: 180, height: 14),
                  SizedBox(height: 14),
                  SkeletonBox(width: double.infinity, height: 1),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 70, height: 12),
                          SizedBox(height: 6),
                          SkeletonBox(width: 140, height: 22),
                          SizedBox(height: 6),
                          SkeletonBox(width: 120, height: 10),
                        ],
                      ),
                      SkeletonBox(width: 62, height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDataSkeleton extends StatelessWidget {
  const HomeDataSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, -20),
          child: SizedBox(
            height: 420,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(color: const Color(0xFFD6E4FF)),
                ),
                const Positioned(
                  top: 16,
                  left: 16,
                  child: SkeletonLoader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 142, height: 18),
                        SizedBox(height: 8),
                        SkeletonBox(width: 104, height: 18),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                      left: 150,
                      right: 24,
                      top: 50,
                      bottom: 10,
                    ),
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: const HotelCardSkeleton(
                          margin: EdgeInsets.only(right: 16),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const HotelCardSkeleton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonLoader(child: SkeletonBox(width: 148, height: 20)),
              SizedBox(height: 16),
              HotelCardSkeleton(),
              HotelCardSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchResultsSkeletonPage extends StatelessWidget {
  const SearchResultsSkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  ),
                ),
                child: const SkeletonLoader(
                  child: Row(
                    children: [
                      SkeletonBox(width: 40, height: 40),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 150, height: 18),
                            SizedBox(height: 8),
                            SkeletonBox(width: 110, height: 12),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      SkeletonBox(width: 40, height: 40),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 16),
                        SkeletonLoader(
                          child: Row(
                            children: [
                              Expanded(child: SkeletonBox(height: 42)),
                              SizedBox(width: 12),
                              SkeletonBox(width: 92, height: 42),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        HotelCardSkeleton(),
                        HotelCardSkeleton(),
                        HotelCardSkeleton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
