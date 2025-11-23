import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoService {
  Future<Map<String, dynamic>?> getDailyForecast({
    required double lat,
    required double lon,
  }) async {
    final Uri url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto',
    );
    final http.Response res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}
