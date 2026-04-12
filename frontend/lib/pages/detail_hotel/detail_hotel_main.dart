import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/hotel_card.dart';

void main() => runApp(const HotelApp());

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: const ,
      // title: 'The Ritz London',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: const HotelDetailScreen(),
    );
  }
}

class RoomModel {
  final String name;
  final double sizeM2;
  final int guests;
  final String bedType;
  final int pricePerNight;
  final String image;

  const RoomModel({
    required this.name,
    required this.sizeM2,
    required this.guests,
    required this.bedType,
    required this.pricePerNight,
    required this.image,
  });
}

// ─────────────────────────────────────────────
//  MOCK DATA  (swap with real API data)
// ─────────────────────────────────────────────
//  image_1  → hero/cover photo
//  image_2  → gallery left
//  image_3  → gallery right
//  image_4  → Junior Suite
//  image_5  → Deluxe Premium
//  image_6  → Corner Suite
//  image_7  → Family Suite
//  image_8  → map background
// ─────────────────────────────────────────────
const _heroImage = 'image_1';
const _galleryImg1 = 'image_2';
const _galleryImg2 = 'image_3';

final _rooms = const <RoomModel>[
  RoomModel(
    name: 'Junior Suite',
    sizeM2: 24,
    guests: 1,
    bedType: '1 King bed',
    pricePerNight: 23273132,
    image: 'image_4',
  ),
  RoomModel(
    name: 'Deluxe Premium',
    sizeM2: 32,
    guests: 2,
    bedType: '1 Double bed',
    pricePerNight: 28800500,
    image: 'image_5',
  ),
  RoomModel(
    name: 'Corner Suite',
    sizeM2: 37,
    guests: 2,
    bedType: '1 Double bed',
    pricePerNight: 30608111,
    image: 'image_6',
  ),
  RoomModel(
    name: 'Family Suite',
    sizeM2: 49,
    guests: 4,
    bedType: '1 Double bed, 2 Single bed',
    pricePerNight: 40111123,
    image: 'image_7',
  ),
];

class HotelDetailScreen extends StatelessWidget {
  const HotelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _HotelInfoCard(),
                _PhotoGallery(),
                SizedBox(height: 20),
                _AboutSection(),
                _AmenitiesSection(),
                _AvailableRoomsSection(),
                _LocationSection(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.favorite_border, size: 18),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _PlaceholderImage(tag: _heroImage, fit: BoxFit.cover),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black12],
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'THE RITZ\nLONDON',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    height: 1.4,
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

class _HotelInfoCard extends StatelessWidget {
  const _HotelInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'The Ritz London',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              // 5-star row
              Row(
                children: List.generate(
                  5,
                  (_) => const Icon(
                    Icons.star,
                    color: Color(0xFFFFC107),
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1565C0), size: 14),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Westminster Borough, London',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 15),
              const SizedBox(width: 4),
              const Text(
                '4.9/5',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFC107),
                ),
              ),
              const SizedBox(width: 14),
              // Stacked avatar circles (overlap via Stack + Positioned)
              SizedBox(
                width: 72,
                height: 26,
                child: Stack(
                  children: List.generate(3, (i) {
                    return Positioned(
                      left: i * 18.0,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.primaries[i * 3],
                        child: Text(
                          ['A', 'B', 'C'][i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        height: 130,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _PlaceholderImage(tag: _galleryImg1, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _PlaceholderImage(tag: _galleryImg2, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Since opening its doors in 1906, The Ritz London has become the '
            'benchmark for luxury hotels. Located in the heart of Westminster, '
            'this iconic landmark offers impeccable service, opulent interiors, '
            'and world-class dining that defines British elegance.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection();

  static const _amenities = [
    (Icons.wifi, 'Wi-Fi'),
    (Icons.local_parking, 'Parking'),
    (Icons.smoke_free, 'Non-Smoking'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amenities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF1565C0), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: _amenities.map((a) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(a.$1, size: 18, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      a.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // ── Nav pill bar ──
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _NavPillItem(
                  icon: Icons.home_filled,
                  label: 'Home',
                  active: true,
                ),
                _NavPillItem(icon: Icons.directions_run, label: 'Activity'),
                _NavPillItem(icon: Icons.local_offer_outlined, label: 'Promo'),
                _NavPillItem(icon: Icons.settings, label: 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavPillItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavPillItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: active
          ? BoxDecoration(
              // Semi-transparent highlight for active tab
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(50),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          if (active) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailableRoomsSection extends StatelessWidget {
  const _AvailableRoomsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Rooms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => _RoomCard(room: _rooms[i]),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // ensures image respects borderRadius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: _PlaceholderImage(tag: room.image, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + price row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${room.sizeM2.toStringAsFixed(0)}.0 m²',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${_formatPrice(room.pricePerNight)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const Text(
                          '/night',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Guest + bed row ──
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.guests} Guest',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.bed_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        room.bedType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── CTA button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Select Room',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Locations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  _PlaceholderImage(tag: 'image_8', fit: BoxFit.cover),
                  ..._labels.map(
                    (l) => Positioned(
                      left: l.dx,
                      top: l.dy,
                      child: _MapChip(text: l.text, isMain: l.isMain),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final _labels = [
    _Label('Gaia Mayfair', 28, 18, false),
    _Label('The Wolseley', 195, 16, false),
    _Label('The Ritz London', 105, 88, true),
    _Label('Green Park', 18, 130, false),
  ];
}

class _Label {
  final String text;
  final double dx, dy;
  final bool isMain;
  const _Label(this.text, this.dx, this.dy, this.isMain);
}

class _MapChip extends StatelessWidget {
  final String text;
  final bool isMain;
  const _MapChip({required this.text, required this.isMain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isMain ? const Color(0xFFE53935) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isMain ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String tag;
  final BoxFit fit;
  const _PlaceholderImage({required this.tag, required this.fit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDDDDD),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF999999),
          ),
        ),
      ),
    );
  }
}
