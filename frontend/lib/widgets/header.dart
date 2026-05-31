// ============================================================
// FILE: gradient_scroll_header.dart
//
// Usage:
//   - GradientScrollHeader  -> main wrapper for the body
//   - HeaderAction          -> navbar icon action
//   - HeaderLocation        -> existing location widget
//
// Example usage is at the bottom (class ExampleHomePage).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// 1. Small reusable components
// ─────────────────────────────────────────────

/// Icon button for either side of the navbar.
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onTap;

  /// Shows a small red badge when the count is greater than zero.
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, color: Colors.white, size: 22)),
            if (badgeCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
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

/// Location widget used in the header.
class HeaderLocation extends StatelessWidget {
  const HeaderLocation({super.key, required this.location, this.onTap});

  final String location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. Main widget: GradientScrollHeader
// ─────────────────────────────────────────────

/// Gradient header that switches to a solid navbar while scrolling.
///
/// Parameter:
/// - [leading]       : left navbar widget, usually HeaderLocation
/// - [actions]       : right navbar widgets, usually HeaderAction
/// - [expandedHeight]: gradient area height, defaults to 160
/// - [gradientColors]: gradient colors
/// - [navbarColor]   : solid navbar color while scrolling
/// - [body]          : scrollable content below the header
/// - [flexibleContent]: extra content inside the gradient area
class GradientScrollHeader extends StatefulWidget {
  const GradientScrollHeader({
    super.key,
    this.leading,
    this.actions = const [],
    this.expandedHeight = 160.0,
    this.gradientColors = const [
      Color(0xFF0E4399),
      Color(0xFF3B82F6),
      Color(0xFFF5F7F8),
    ],
    this.gradientStops = const [0.2, 0.6, 1.0],
    this.navbarColor = const Color(0xFF0E4399),
    required this.body,
    this.flexibleContent,
    this.scrollController,
    this.bodyTopPadding,
  });

  /// Widget on the left side of the navbar, usually HeaderLocation.
  final Widget? leading;

  /// Widgets on the right side of the navbar, usually HeaderAction.
  final List<Widget> actions;

  /// Total height of the collapsible gradient area.
  final double expandedHeight;

  /// Header background gradient colors.
  final List<Color> gradientColors;

  /// Gradient stop positions. Must match gradientColors length.
  final List<double> gradientStops;

  /// Solid navbar color after scrolling.
  final Color navbarColor;

  /// Main scrollable page content.
  final Widget body;

  /// Extra content inside the gradient area, such as a search bar.
  /// This fades out while scrolling.
  final Widget? flexibleContent;

  /// Optional external scroll controller. A local one is created when null.
  final ScrollController? scrollController;

  /// Optional top padding for the body. Defaults to expandedHeight.
  final double? bodyTopPadding;

  @override
  State<GradientScrollHeader> createState() => _GradientScrollHeaderState();
}

class _GradientScrollHeaderState extends State<GradientScrollHeader> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  // Scroll distance before the navbar becomes fully solid.
  double get _solidThreshold => widget.expandedHeight * 0.5;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset.clamp(0.0, _solidThreshold);
    if (offset != _scrollOffset) {
      setState(() => _scrollOffset = offset);
    }
  }

  @override
  void dispose() {
    // Only dispose controllers owned by this widget.
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  /// Transition progress: 0.0 = expanded, 1.0 = fully collapsed.
  double get _progress => (_scrollOffset / _solidThreshold).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final navbarHeight = topPadding + kToolbarHeight;

    // Navbar color moves from transparent to solid while scrolling.
    final navbarBg = Color.lerp(
      Colors.transparent,
      widget.navbarColor,
      _progress,
    )!;

    // Keep the status bar icons light because the header background is blue.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              controller: _scrollController,
              child: Stack(
                children: [
                  // 1. Gradient background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _GradientHeaderBackground(
                      height: widget.expandedHeight,
                      width: double.infinity,
                      gradientColors: widget.gradientColors,
                      gradientStops: widget.gradientStops,
                      topPadding: topPadding,
                      navbarHeight: navbarHeight,
                      flexibleContent: widget.flexibleContent,
                      scrollProgress: _progress,
                    ),
                  ),

                  // 2. Page body above the gradient
                  Padding(
                    padding: EdgeInsets.only(
                      top: widget.bodyTopPadding ?? widget.expandedHeight,
                    ),
                    child: widget.body,
                  ),
                ],
              ),
            ),

            // Fixed navbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  // Solid navbar background behind the navbar content.
                  // Ignore touches when transparent so it does not block content below.
                  IgnorePointer(
                    ignoring: _progress == 0,
                    child: AnimatedContainer(
                      duration: Duration.zero,
                      height: navbarHeight,
                      decoration: BoxDecoration(
                        color: navbarBg,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.15 * _progress,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Navbar content
                  Container(
                    height: navbarHeight,
                    padding: EdgeInsets.only(
                      top: topPadding,
                      left: 24,
                      right: 24,
                    ),
                    child: Row(
                      children: [
                        // Leading
                        if (widget.leading != null)
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: widget.leading!,
                            ),
                          ),

                        // Actions
                        ...widget.actions,
                      ],
                    ),
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

// ─────────────────────────────────────────────
// 3.  INTERNAL: Background Gradasi
// ─────────────────────────────────────────────

class _GradientHeaderBackground extends StatelessWidget {
  const _GradientHeaderBackground({
    required this.height,
    required this.width,
    required this.gradientColors,
    required this.gradientStops,
    required this.topPadding,
    required this.navbarHeight,
    required this.scrollProgress,
    this.flexibleContent,
  });

  final double height;
  final double width;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final double topPadding;
  final double navbarHeight;
  final double scrollProgress;
  final Widget? flexibleContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: gradientStops,
        ),
      ),
      child: flexibleContent != null
          ? Padding(
              padding: EdgeInsets.only(
                top: navbarHeight + 8,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              // Fade out flexible content saat scroll
              child: Opacity(
                opacity: (1.0 - scrollProgress * 2).clamp(0.0, 1.0),
                child: flexibleContent,
              ),
            )
          : null,
    );
  }
}
