import 'package:flutter/material.dart';

class HomeSearchCard extends StatelessWidget {
  final VoidCallback? onSearch;

  const HomeSearchCard({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -60),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withAlpha(40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search hotel input
            _buildSearchField(
              icon: Icons.search_rounded,
              text: 'Search hotel or location',
              isHint: true,
            ),
            const SizedBox(height: 12),
            // Date range
            _buildSearchField(
              icon: Icons.calendar_today_rounded,
              text: 'Tue, 3 Mar 2026 - Wed, 4 Mar 2026',
              isHint: false,
            ),
            const SizedBox(height: 12),
            // Night count
            Text('1 night', style: TextStyle(fontSize: 12)),
            // _buildSearchField(
            //   icon: Icons.nightlight_round,
            //   text: '1 Night',
            //   isHint: false,
            // ),
            const SizedBox(height: 16),
            // Search button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E293B).withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed:
                      onSearch ??
                      () {
                        Navigator.pushNamed(context, '/search-results');
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),

                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required IconData icon,
    required String text,
    required bool isHint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF94A3B8), width: 0.6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isHint ? const Color(0xFF475569) : const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isHint
                    ? const Color(0xFF475569)
                    : const Color(0xFF1E293B),
                fontWeight: isHint ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
