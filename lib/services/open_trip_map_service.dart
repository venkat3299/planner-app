import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenTripMapService {
  OpenTripMapService({required this.apiKey});
  final String apiKey;

  Future<List<Map<String, dynamic>>> searchPlaces({
    required double lat,
    required double lon,
    double radiusMeters = 1000,
    int limit = 20,
  }) async {
    final Uri url = Uri.parse(
      'https://api.opentripmap.com/0.1/en/places/radius?radius=$radiusMeters&lon=$lon&lat=$lat&apikey=$apiKey&limit=$limit',
    );
    final http.Response res = await http.get(url);
    if (res.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
      final List<dynamic> features = body['features'] as List<dynamic>? ?? <dynamic>[];
      return features.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }
}


