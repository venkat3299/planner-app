import 'dart:convert';
import 'package:http/http.dart' as http;

class AmadeusService {
  AmadeusService({required this.clientId, required this.clientSecret});
  final String clientId;
  final String clientSecret;

  String? _accessToken;
  DateTime? _expiresAt;

  Future<void> _ensureToken() async {
    if (_accessToken != null && _expiresAt != null && _expiresAt!.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return;
    }
    final Uri url = Uri.parse('https://test.api.amadeus.com/v1/security/oauth2/token');
    final http.Response res = await http.post(
      url,
      headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded'},
      body: <String, String>{
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );
    if (res.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
      _accessToken = body['access_token'] as String?;
      final int expiresIn = (body['expires_in'] as num?)?.toInt() ?? 0;
      _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    } else {
      _accessToken = null;
      _expiresAt = null;
    }
  }

  Future<Map<String, dynamic>?> searchFlights({
    required String origin,
    required String destination,
    required String departureDate, // YYYY-MM-DD
    int adults = 1,
  }) async {
    await _ensureToken();
    if (_accessToken == null) return null;
    final Uri url = Uri.parse(
      'https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=$origin&destinationLocationCode=$destination&departureDate=$departureDate&adults=$adults&currencyCode=EUR',
    );
    final http.Response res = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer $_accessToken'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}


