import 'package:flutter/material.dart';

// Model
class ReviewFilter {
  final String label;
  final int? stars; // null = "All Review"

  const ReviewFilter({required this.label, this.stars});
}

// Main Widget
class ReviewFilterBar extends StatefulWidget {
  final ValueChanged<int?>? onFilterChanged;
  const ReviewFilterBar({super.key, this.onFilterChanged});

  @override
  State<ReviewFilterBar> createState() => _ReviewFilterBarState();
}

class _ReviewFilterBarState extends State<ReviewFilterBar> {
  int _selectedIndex = 0;

  final List<ReviewFilter> _filters = const [
    ReviewFilter(label: 'All Review'),
    ReviewFilter(label: '5', stars: 5),
    ReviewFilter(label: '4', stars: 4),
    ReviewFilter(label: '3', stars: 3),
    ReviewFilter(label: '2', stars: 2),
    ReviewFilter(label: '1', stars: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFD6E4F7),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_filters.length, (index) {
          return _FilterChip(
            filter: _filters[index],
            isActive: _selectedIndex == index,
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onFilterChanged?.call(_filters[index].stars);
            },
          );
        }),
      ),
    );
  }
}

// Chip item
class _FilterChip extends StatelessWidget {
  final ReviewFilter filter;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF3B82F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.white,
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (filter.stars != null) ...[
              _StarRow(count: filter.stars!, isActive: isActive),
              const SizedBox(width: 6),
            ],
            Text(
              filter.label,
              style: const TextStyle(
                color: activeColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Star
class _StarRow extends StatelessWidget {
  final int count;
  final bool isActive;
  const _StarRow({required this.count, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (_) => Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.black26, // border/outline
              size: 20,
            ),
            Icon(
              Icons.star_rounded,
              color: Color(0xFFFBBF24),
              size: 17, // sedikit lebih kecil
            ),
          ],
        ),
      ),
    );
  }
}
