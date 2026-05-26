// ============================================================
// FILE: gradient_scroll_header.dart
//
// Cara pakai:
//   - GradientScrollHeader  → widget utama, wrap body kamu
//   - HeaderAction          → komponen aksi (icon button) buat navbar
//   - HeaderLocation        → komponen lokasi yang sudah ada
//
// Contoh penggunaan ada di bawah (class ExampleHomePage)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// 1.  KOMPONEN KECIL (bisa dipakai di mana pun)
// ─────────────────────────────────────────────

/// Tombol ikon untuk ditaruh di kanan/kiri navbar.
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onTap;

  /// Kalau > 0, tampilkan badge merah kecil di atas ikon.
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

/// Widget lokasi seperti yang sudah ada di header.
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
// 2.  WIDGET UTAMA: GradientScrollHeader
// ─────────────────────────────────────────────

/// Widget header dengan gradasi yang otomatis berubah jadi
/// solid navbar transparan saat konten di-scroll ke atas.
///
/// Parameter:
/// - [leading]       : widget di kiri navbar (biasanya HeaderLocation)
/// - [actions]       : list widget di kanan navbar (biasanya HeaderAction)
/// - [expandedHeight]: tinggi area gradasi (default 160)
/// - [gradientColors]: warna gradasi (default biru seperti desain asal)
/// - [navbarColor]   : warna solid navbar saat scroll (default biru tua)
/// - [body]          : konten scrollable di bawah header
/// - [flexibleContent]: konten tambahan di dalam area gradasi
///   (misal: search box, dll.)
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

  /// Widget di sisi kiri navbar (misal: HeaderLocation).
  final Widget? leading;

  /// List widget di sisi kanan navbar (misal: [HeaderAction(...)]).
  final List<Widget> actions;

  /// Tinggi total area gradasi yang bisa di-collapse.
  final double expandedHeight;

  /// Warna-warna gradasi background header.
  final List<Color> gradientColors;

  /// Stop posisi gradasi (harus sama panjang dengan gradientColors).
  final List<double> gradientStops;

  /// Warna solid navbar ketika sudah di-scroll.
  final Color navbarColor;

  /// Konten utama halaman (scrollable).
  final Widget body;

  /// Konten ekstra di dalam area gradasi (misal search bar).
  /// Widget ini akan fade out saat scroll.
  final Widget? flexibleContent;

  /// Opsional: scroll controller eksternal. Kalau null, dibuat sendiri.
  final ScrollController? scrollController;

  /// Opsional: Jarak padding atas untuk body. Default = expandedHeight
  final double? bodyTopPadding;

  @override
  State<GradientScrollHeader> createState() => _GradientScrollHeaderState();
}

class _GradientScrollHeaderState extends State<GradientScrollHeader> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  // Seberapa jauh scroll sampai navbar jadi fully solid.
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
    // Hanya dispose kalau kita yang buat controller-nya
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  /// Progress transisi: 0.0 = expanded, 1.0 = fully collapsed/solid
  double get _progress => (_scrollOffset / _solidThreshold).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final navbarHeight = topPadding + kToolbarHeight;

    // Warna navbar: transparan → solid sesuai scroll
    final navbarBg = Color.lerp(
      Colors.transparent,
      widget.navbarColor,
      _progress,
    )!;

    // Status bar style: gelap (untuk gradasi terang) selalu putih
    // karena latar belakang header biru.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // ── SCROLLABLE CONTENT ──────────────────────────────
            SingleChildScrollView(
              controller: _scrollController,
              child: Stack(
                children: [
                  // 1. Latar belakang gradasi (di paling belakang)
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

                  // 2. Body konten halaman (di atas gradasi)
                  Padding(
                    padding: EdgeInsets.only(
                      top: widget.bodyTopPadding ?? widget.expandedHeight,
                    ),
                    child: widget.body,
                  ),
                ],
              ),
            ),

            // ── FIXED NAVBAR (di atas segalanya) ────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  // Latar belakang solid navbar (di belakang konten navbar)
                  // Jika belum di-scroll (_progress == 0), abaikan sentuhan
                  // agar tidak menutupi elemen di bawahnya secara tidak sengaja.
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
                  // Konten navbar (lokasi, icon, dsb.)
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
                          Expanded(child: widget.leading!),

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
