import 'dart:convert';
import 'package:http/http.dart' as http;

/// Free geocoding service using Nominatim (OpenStreetMap)
class GeocodingService {
  GeocodingService._();
  static final GeocodingService instance = GeocodingService._();

  /// Search for locations by name
  /// Returns list of places with coordinates
  Future<List<LocationResult>> searchLocation(String query) async {
    if (query.trim().isEmpty) return <LocationResult>[];

    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=10&addressdetails=1',
    );

    try {
      final http.Response res = await http.get(
        url,
        headers: <String, String>{
          'User-Agent': 'TripPlannerApp/1.0', // Required by Nominatim
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> results = jsonDecode(res.body) as List<dynamic>;
        return results.map((dynamic e) {
          final Map<String, dynamic> item = e as Map<String, dynamic>;
          return LocationResult(
            name: item['display_name'] as String? ?? '',
            latitude: double.tryParse(item['lat'] as String? ?? '0') ?? 0.0,
            longitude: double.tryParse(item['lon'] as String? ?? '0') ?? 0.0,
            type: item['type'] as String? ?? '',
            address: item['address'] as Map<String, dynamic>?,
          );
        }).toList();
      }
    } catch (e) {
      // Handle error silently
    }
    return <LocationResult>[];
  }

  /// Reverse geocoding: get location name from coordinates
  Future<String?> getLocationName(double lat, double lon) async {
    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
    );

    try {
      final http.Response res = await http.get(
        url,
        headers: <String, String>{
          'User-Agent': 'TripPlannerApp/1.0',
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> result =
            jsonDecode(res.body) as Map<String, dynamic>;
        return result['display_name'] as String?;
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }
}

class LocationResult {
  LocationResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.type,
    this.address,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? type;
  final Map<String, dynamic>? address;

  String get shortName {
    if (address != null) {
      final String? city = address!['city'] as String?;
      final String? town = address!['town'] as String?;
      final String? village = address!['village'] as String?;
      return city ?? town ?? village ?? name.split(',').first;
    }
    return name.split(',').first;
  }
}
