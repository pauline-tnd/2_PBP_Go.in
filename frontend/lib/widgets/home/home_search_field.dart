import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/providers/hotel_search_provider.dart';
import 'package:frontend/utils/image_path.dart';

class HomeSearchField extends StatefulWidget {
  final void Function(Hotel hotel) onHotelSelected;
  final void Function(String query)? onSearch;
  final ValueChanged<String>? onChanged;

  const HomeSearchField({
    super.key,
    required this.onHotelSelected,
    this.onSearch,
    this.onChanged,
  });

  @override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  static const Object _tapRegionGroupId = Object();
  static const Color _darkBlue = Color(0xFF0E4399);
  static const Color _primary = Color(0xFF3B82F6);
  static const Color _lightBlue = Color(0xFFDBEAFE);

  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlay;
  Timer? _debounce;
  Timer? _hideOverlayTimer;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _scheduleHideOverlay();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlayTimer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    _hideOverlayTimer?.cancel();
    _hideOverlay();

    _overlay = OverlayEntry(
      builder: (_) {
        return Positioned(
          width: _getWidth(),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 54),
            child: TapRegion(
              groupId: _tapRegionGroupId,
              child: Consumer<HotelSearchProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return _buildLoadingTile();

                  if (provider.errorMessage != null) {
                    return _buildMessageTile(
                      icon: Icons.wifi_off_rounded,
                      message: provider.errorMessage!,
                    );
                  }

                  if (!provider.hasResult) {
                    return _buildMessageTile(
                      icon: Icons.search_off_rounded,
                      message: 'No hotels found',
                    );
                  }

                  // Show Result
                  return _buildDropdown(provider.hotels);
                },
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _hideOverlayTimer?.cancel();
    _overlay?.remove();
    _overlay = null;
  }

  void _scheduleHideOverlay() {
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(milliseconds: 180), _hideOverlay);
  }

  double _getWidth() {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.width ?? 300;
  }

  Widget _buildDropdown(List<Hotel> hotels) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      shadowColor: _darkBlue.withValues(alpha: 0.15),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _lightBlue),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: hotels.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: _lightBlue.withValues(alpha: 0.6),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (_, i) => _buildTile(hotels[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(Hotel hotel) {
    final normalizedPath = normalizeImagePath(hotel.imagePath);
    final isNetworkImage = isNetworkImagePath(normalizedPath);

    return InkWell(
      onTapDown: (_) => _hideOverlayTimer?.cancel(),
      onTap: () {
        _ctrl.text = hotel.name;
        _hideOverlay();
        context.read<HotelSearchProvider>().clear();
        widget.onHotelSelected(hotel);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Image thumbnail / placeholder
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(10),
                image: normalizedPath.isNotEmpty
                    ? DecorationImage(
                        image: isNetworkImage
                            ? NetworkImage(
                                normalizedPath.startsWith('//')
                                    ? 'https:$normalizedPath'
                                    : normalizedPath,
                              )
                            : AssetImage(normalizedPath) as ImageProvider,
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      )
                    : null,
              ),
              child: normalizedPath.isEmpty
                  ? const Icon(Icons.hotel_rounded, color: _darkBlue, size: 22)
                  : null,
            ),
            const SizedBox(width: 12),

            // Name, location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: _primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(hotel.pricePerNight),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _darkBlue,
                  ),
                ),
                Text(
                  '/night',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── State tiles ──────────────────────────────────────────

  Widget _buildLoadingTile() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Searching hotels...',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile({required IconData icon, required String message}) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 18),
            const SizedBox(width: 10),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapRegionGroupId,
      onTapOutside: (_) => _focus.unfocus(),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          height: 50,
          child: Consumer<HotelSearchProvider>(
            builder: (context, provider, _) {
              return TextField(
                controller: _ctrl,
                focusNode: _focus,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search hotel or location',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _primary.withValues(alpha: 0.7),
                    size: 22,
                  ),

                  // Loading / clear icon
                  suffixIcon: provider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        )
                      : _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () {
                            _ctrl.clear();
                            _hideOverlay();
                            provider.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _lightBlue, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  widget.onChanged?.call(val);
                  setState(() {}); // update suffixIcon
                  _debounce?.cancel();

                  if (val.trim().isEmpty) {
                    _hideOverlay();
                    provider.clear();
                    return;
                  }

                  // Wait 500ms after typing
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    provider.search(val);
                    _showOverlay();
                  });
                },
                onTap: () {
                  _hideOverlayTimer?.cancel();
                  if (provider.hasResult || provider.errorMessage != null) {
                    _showOverlay();
                  }
                },
                onSubmitted: (val) {
                  _hideOverlay();
                  widget.onSearch?.call(val);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }
}
