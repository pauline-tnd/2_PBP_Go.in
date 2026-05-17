import 'dart:async';

import 'package:flutter/material.dart';

import 'login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _iconSlideAnimation;
  late final Animation<double> _fullLogoSlideAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // logo.png: mulai dari tengah, lalu bergerak ke kiri
    _iconSlideAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // Go.in-Logo.png: mulai dari kiri, lalu bergerak ke kanan
    _fullLogoSlideAnimation = Tween<double>(begin: -70, end: 70).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _controller.forward();
    });

    _timer = Timer(const Duration(milliseconds: 1900), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => const LoginPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final middleLayerWidth = screenWidth * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFDBEAFE),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Layer 1: Go.in-Logo.png
              // Posisi awal: kiri layar, tapi tengah secara vertikal
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(_fullLogoSlideAnimation.value, 0),
                    child: Image.asset(
                      'assets/images/Go.in-Logo.png',
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Layer 2: layer tengah
              // Tetap ada meskipun animasi sudah selesai
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 200,
                child: Container(
                  width: middleLayerWidth,
                  color: const Color(0xFFDBEAFE),
                ),
              ),

              // Layer 3: logo.png
              // Posisi awal: tengah layar
              Center(
                child: Transform.translate(
                  offset: Offset(_iconSlideAnimation.value, 0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 106,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
