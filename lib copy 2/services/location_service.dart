import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Unified location service — works on both web and mobile.
/// On web: geolocator_web uses the browser Geolocation API.
/// On mobile: geolocator uses native GPS.
/// Reverse geocoding via OpenStreetMap Nominatim (pure HTTP, no extra package).
class LocationService extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String _locationName = 'Localisation...';
  String _city = 'Yaoundé';
  bool _isLoading = false;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get locationName => _locationName;
  String get city => _city;
  bool get isLoading => _isLoading;
  bool get hasLocation => _latitude != null;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _locationName = 'Localisation en cours...';
    notifyListeners();

    try {
      Position? position;

      if (kIsWeb) {
        // On web: geolocator_web handles permission via browser prompt
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } else {
        // On mobile: request permission first
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.deniedForever ||
            perm == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      }

      _latitude = position.latitude;
      _longitude = position.longitude;
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location error: $e');
      _setDefaultLocation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setDefaultLocation() {
    _latitude = 3.8667;
    _longitude = 11.5167;
    _locationName = 'Yaoundé, Cameroun';
    _city = 'Yaoundé';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lng&format=json&accept-language=fr',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'MetalLinkCM/1.0'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final suburb = address['suburb'] as String?;
          final quarter = address['quarter'] as String?;
          final cityName = (address['city'] ??
                  address['town'] ??
                  address['village'] ??
                  'Yaoundé') as String;
          _city = cityName;
          final neighbourhood = suburb ?? quarter;
          _locationName = (neighbourhood != null && neighbourhood.isNotEmpty)
              ? '$neighbourhood, $cityName'
              : cityName;
          return;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    _locationName = 'Yaoundé, Cameroun';
    _city = 'Yaoundé';
  }
}
