import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/models/nominatim.dart';
import 'package:frontend/providers/location_provider.dart';
import 'package:frontend/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestLocationPermission() async {
  var status = await Permission.location.status;

  if (status.isGranted) return true;

  status = await Permission.location.request();

  if (status.isGranted) return true;

  if (status.isPermanentlyDenied) {
    await openAppSettings();
  }

  return false;
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const String _maptilerKey = 'E9ZFe6B1DmH71sbyAHar';

  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  LatLng _center = const LatLng(-6.2088, 106.8456); // Jakarta fallback
  String _pickedAddress = '';
  List<NominatimResult> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    // Restore the previous location when one has already been selected.
    final loc = context.read<LocationProvider>();
    if (loc.hasLocation) {
      _center = LatLng(loc.lat!, loc.lng!);
      _pickedAddress = loc.address;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Choose Location"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: (pos, _) {
                // Keep the picked point aligned with the map center.
                setState(() {
                  _center = pos.center;
                  _pickedAddress = '';
                });
              },
              onMapEvent: (event) {
                // Refresh the address after the map stops moving.
                if (event is MapEventMoveEnd) {
                  _reverseGeocode(_center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$_maptilerKey',
                userAgentPackageName: 'com.example.frontend',
              ),
            ],
          ),

          // Center pin
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, size: 44, color: Color(0xFF3B82F6)),
                SizedBox(height: 44),
              ],
            ),
          ),

          // Search bar and results
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                _buildSearchBar(),
                if (_searchResults.isNotEmpty) _buildSearchResults(),
              ],
            ),
          ),

          // Bottom panel
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomPanel()),
        ],
      ),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Search Location...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (val) {
          if (val.length >= 3) _searchPlace(val);
          if (val.isEmpty) setState(() => _searchResults = []);
        },
      ),
    );
  }

  // Search results
  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16),
        itemBuilder: (_, i) {
          final result = _searchResults[i];
          return ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
            title: Text(
              result.displayName,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSearchResult(result),
          );
        },
      ),
    );
  }

  // Bottom panel
  Widget _buildBottomPanel() {
    final hasSavedLocation = context.watch<LocationProvider>().hasLocation;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: _isLoadingAddress
                    ? const Text(
                        'Fetching location name...',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    : Text(
                        _pickedAddress.isEmpty
                            ? 'Move the map to choose a location'
                            : _pickedAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: _pickedAddress.isEmpty
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // GPS button
          OutlinedButton.icon(
            onPressed: _useGPS,
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Use GPS Location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),

          if (hasSavedLocation) ...[
            OutlinedButton.icon(
              onPressed: _unsetLocation,
              icon: const Icon(Icons.location_off_outlined, size: 18),
              label: const Text('Unset Location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Confirm button
          ElevatedButton(
            onPressed: _pickedAddress.isEmpty ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Choose This Location',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Logic

  Future<void> _reverseGeocode(LatLng latlng) async {
    setState(() => _isLoadingAddress = true);
    final addr = await ApiService.reverseGeocode(
      latlng.latitude,
      latlng.longitude,
    );
    if (mounted) {
      setState(() {
        _pickedAddress = addr;
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchPlace(String query) async {
    setState(() => _isSearching = true);
    final results = await ApiService.search(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(NominatimResult result) {
    final latlng = LatLng(result.lat, result.lon);
    _mapController.move(latlng, 15);
    setState(() {
      _center = latlng;
      _pickedAddress = result.displayName;
      _searchResults = [];
      _searchCtrl.clear();
    });
  }

  Future<void> _useGPS() async {
    final provider = context.read<LocationProvider>();

    final success = await provider.fetchCurrentLocation(
      onGpsDisabled: () async {
        // Dialog context
        return showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('GPS Disabled'),
            content: const Text('Please enable Location Services to use GPS.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      },
    );

    if (success && mounted) {
      final latlng = LatLng(provider.lat!, provider.lng!);
      _mapController.move(latlng, 16);
      setState(() {
        _center = latlng;
        _pickedAddress = provider.address;
      });
    } else if (mounted) {
      context.showAppSnackBar('Failed to get GPS location', isError: true);
    }
  }

  void _confirm() {
    context.read<LocationProvider>().setLocation(
      _center.latitude,
      _center.longitude,
      _pickedAddress,
    );
    Navigator.pop(context);
  }

  void _unsetLocation() {
    context.read<LocationProvider>().clearLocation();
    Navigator.pop(context);
  }
}
