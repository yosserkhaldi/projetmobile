import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    this.initialLatitude,
    this.initialLongitude,
    this.initialLabel,
    super.key,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialLabel;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _tunis = LatLng(36.8065, 10.1815);
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _locationService = AccidentLocationService();

  late LatLng _point;
  String _label = 'Position sur la carte';
  double _accuracy = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _point = widget.initialLatitude != null && widget.initialLongitude != null
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _tunis;
    _label = widget.initialLabel ?? _label;
    if (widget.initialLatitude == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _useMyLocation());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lieu de l’accident')),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Rechercher une adresse',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Rechercher',
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _point,
                    initialZoom: 16,
                    onTap: (_, point) => _selectPoint(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.flutter_workshops_5sae1_2627',
                    ),
                    DragMarkers(
                      markers: [
                        DragMarker(
                          point: _point,
                          size: const Size.square(56),
                          offset: const Offset(0, -22),
                          scrollMapNearEdge: true,
                          builder: (_, _, isDragging) => Icon(
                            isDragging
                                ? Icons.edit_location_alt
                                : Icons.location_on,
                            size: 56,
                            color: AppColors.primary,
                          ),
                          onDragEnd: (_, point) => _selectPoint(point),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'gps-location',
                    tooltip: 'Ma position',
                    onPressed: _loading ? null : _useMyLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                const Positioned(
                  left: 8,
                  bottom: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white70),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Text(
                        '© OpenStreetMap',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
                if (_loading)
                  const ColoredBox(
                    color: Color(0x33000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIEU SÉLECTIONNÉ',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${_point.latitude.toStringAsFixed(6)}, '
                  '${_point.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.errorText),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _confirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmer ce lieu'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _useMyLocation() async {
    await _run(() async {
      final result = await _locationService.determineLocation();
      _applyResult(result, moveMap: true);
    });
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.length < 3) {
      setState(() => _error = 'Saisissez au moins 3 caractères.');
      return;
    }
    await _run(() async {
      final result = await _locationService.searchAddress(query);
      _applyResult(result, moveMap: true);
    });
  }

  Future<void> _selectPoint(LatLng point) async {
    setState(() {
      _point = point;
      _error = null;
    });
    await _run(() async {
      final result = await _locationService.resolveCoordinates(
        point.latitude,
        point.longitude,
      );
      _applyResult(result);
    });
  }

  Future<void> _run(Future<void> Function() operation) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await operation();
    } on AccidentLocationException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de récupérer ce lieu.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyResult(AccidentLocation result, {bool moveMap = false}) {
    if (!mounted) return;
    final point = LatLng(result.latitude, result.longitude);
    setState(() {
      _point = point;
      _label = result.label;
      _accuracy = result.accuracy;
    });
    if (moveMap) _mapController.move(point, 16);
  }

  void _confirm() => Navigator.pop(
    context,
    AccidentLocation(
      label: _label,
      latitude: _point.latitude,
      longitude: _point.longitude,
      accuracy: _accuracy,
    ),
  );
}
