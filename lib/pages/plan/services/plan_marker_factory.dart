import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlanMarkerFactory {
  PlanMarkerFactory._();

  static final PlanMarkerFactory instance = PlanMarkerFactory._();

  static const String _currentMarkerPath = 'assets/icons/mark_current.png';
  static const String _destinationMarkerPath =
      'assets/icons/mark_destination.png';

  Uint8List? _currentMarkerBytes;
  Uint8List? _destinationMarkerBytes;

  final Map<String, Uint8List> _cache = {};
  Future<void>? _initializing;

  bool get isReady =>
      _currentMarkerBytes != null && _destinationMarkerBytes != null;

  Future<void> ensureInitialized({int markerSize = 16}) {
    if (isReady) return Future.value();
    _initializing ??= _loadAllMarkers(markerSize);
    return _initializing!;
  }

  Future<void> _loadAllMarkers(int markerSize) async {
    _currentMarkerBytes ??= await _loadMarker(_currentMarkerPath, markerSize);
    _destinationMarkerBytes ??= await _loadMarker(
      _destinationMarkerPath,
      markerSize,
    );
  }

  Future<Uint8List> _loadMarker(String assetPath, int size) async {
    final cacheKey = '$assetPath-$size';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final byteData = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: size,
        targetHeight: size,
      );
      final frame = await codec.getNextFrame();
      final pngBytes = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (pngBytes == null) {
        throw Exception('Failed to convert asset to PNG bytes');
      }

      final bytes = pngBytes.buffer.asUint8List();
      _cache[cacheKey] = bytes;
      debugPrint('[PlanMarkerFactory] Loaded $assetPath');
      return bytes;
    } catch (e) {
      debugPrint('[PlanMarkerFactory] Failed to load $assetPath -> $e');
      final byteData = await rootBundle.load(assetPath);
      final fallback = byteData.buffer.asUint8List();
      _cache[cacheKey] = fallback;
      return fallback;
    }
  }

  Widget buildCurrentMarker({double width = 16, double height = 16}) {
    if (_currentMarkerBytes != null) {
      return Image.memory(
        _currentMarkerBytes!,
        width: width,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    return Image.asset(
      _currentMarkerPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  Widget buildDestinationMarker({
    required int index,
    double width = 32,
    double height = 32,
  }) {
    final markerImage =
        _destinationMarkerBytes != null
            ? Image.memory(
              _destinationMarkerBytes!,
              width: width,
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            )
            : Image.asset(
              _destinationMarkerPath,
              width: width,
              height: height,
              fit: BoxFit.contain,
            );

    return SizedBox(
      width:
          width + 20, // Beri extra space agar tidak overflow secara horizontal
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle, // Gunakan circle agar lebih compact
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          markerImage,
        ],
      ),
    );
  }
}
