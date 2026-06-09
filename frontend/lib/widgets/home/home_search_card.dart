import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:frontend/pages/search_results_page.dart';
import 'package:frontend/widgets/home/home_search_field.dart';
import 'package:intl/intl.dart';

class HomeSearchCard extends StatefulWidget {
  final VoidCallback? onSearch;

  const HomeSearchCard({super.key, this.onSearch});

  @override
  State<HomeSearchCard> createState() => _HomeSearchCardState();
}

class _HomeSearchCardState extends State<HomeSearchCard> {
  List<DateTime?> _dates = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 1)),
  ];
  String _hotelQuery = '';

  String _formatDate(DateTime? date) {
    return date == null ? '' : DateFormat('EEE, d MMM yyyy').format(date);
  }

  String _getDateRangeText() {
    return _dates.isEmpty || _dates[0] == null
        ? 'Select dates'
        : _dates.length < 2 || _dates[1] == null
        ? _formatDate(_dates[0])
        : '${_formatDate(_dates[0])} - ${_formatDate(_dates[1])}';
  }

  int _getNightCount() {
    return _dates.length < 2 || _dates[0] == null || _dates[1] == null
        ? 0
        : _dates[1]!.difference(_dates[0]!).inDays;
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          // padding: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.range,
                  // Selected date (start & end date)
                  selectedDayHighlightColor: const Color(0xFF3B82F6),

                  // Selected days
                  selectedDayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                  // Days in range
                  dayTextStyle: const TextStyle(color: Color(0xFF1E293B)),

                  // Disabled days
                  disabledDayTextStyle: const TextStyle(
                    color: Color(0xFFCBD5E1),
                  ),

                  // Today
                  todayTextStyle: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),

                  // Month & year header
                  controlsTextStyle: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _dates,
                onValueChanged: (dates) {
                  setState(() => _dates = dates);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSearchResults([String? query]) {
    final searchQuery = query?.trim() ?? _hotelQuery.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          initialQuery: searchQuery.isEmpty ? null : searchQuery,
          dateRange: _getDateRangeText(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 60),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
          HomeSearchField(
            onHotelSelected: (hotel) {
              _openSearchResults(hotel.name);
            },
            onSearch: _openSearchResults,
            onChanged: (query) => _hotelQuery = query,
          ),
          const SizedBox(height: 12),

          // Date field
          GestureDetector(
            onTap: _showDatePicker,
            child: _buildSearchField(
              icon: Icons.calendar_today_rounded,
              text: _getDateRangeText(),
              isHint: false,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            '${_getNightCount()} night(s)',
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onSearch ?? _openSearchResults,
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
        ],
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
