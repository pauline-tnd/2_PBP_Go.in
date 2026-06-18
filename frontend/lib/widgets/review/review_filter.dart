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
  final ValueChanged<String?>? onRoomFilterChanged;
  final List<String> roomTypes;
  final String? selectedRoomType;
  final bool showRoomFilter;

  const ReviewFilterBar({
    super.key,
    this.onFilterChanged,
    this.onRoomFilterChanged,
    this.roomTypes = const [],
    this.selectedRoomType,
    this.showRoomFilter = false,
  });

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 32,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD6E4F7),
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Wrap(
                spacing: isCompact ? 10 : 14,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _FilterChip(
                    filter: _filters[0],
                    isActive: _selectedIndex == 0,
                    onTap: () {
                      setState(() => _selectedIndex = 0);
                      widget.onFilterChanged?.call(_filters[0].stars);
                    },
                  ),
                  if (widget.showRoomFilter)
                    _RoomFilterChip(
                      roomTypes: widget.roomTypes,
                      selectedRoomType: widget.selectedRoomType,
                      onChanged: widget.onRoomFilterChanged,
                    ),
                  ...List.generate(_filters.length - 1, (index) {
                    final filterIndex = index + 1;
                    return _FilterChip(
                      filter: _filters[filterIndex],
                      isActive: _selectedIndex == filterIndex,
                      onTap: () {
                        setState(() => _selectedIndex = filterIndex);
                        widget.onFilterChanged?.call(
                          _filters[filterIndex].stars,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoomFilterChip extends StatelessWidget {
  final List<String> roomTypes;
  final String? selectedRoomType;
  final ValueChanged<String?>? onChanged;

  const _RoomFilterChip({
    required this.roomTypes,
    required this.selectedRoomType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF3B82F6);
    const allRoomsValue = '__all_rooms__';

    return PopupMenuButton<String>(
      tooltip: 'Filter by room',
      onSelected: (value) {
        onChanged?.call(value == allRoomsValue ? null : value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: allRoomsValue,
          child: Text('All Rooms'),
        ),
        ...roomTypes.map(
          (roomType) =>
              PopupMenuItem<String>(value: roomType, child: Text(roomType)),
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selectedRoomType == null
              ? Colors.white
              : activeColor.withValues(alpha: 0.15),
          border: Border.all(
            color: selectedRoomType == null
                ? const Color(0xFFE2E8F0)
                : activeColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                selectedRoomType ?? 'By Room',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: activeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: activeColor,
              size: 20,
            ),
          ],
        ),
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
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.white,
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
