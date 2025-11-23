import 'dart:convert';
import 'package:http/http.dart' as http;

class NavitiaService {
  NavitiaService({required this.apiKey});
  final String apiKey; // Get from navitia.io

  Future<Map<String, dynamic>?> getDepartures(String stopAreaId) async {
    final Uri url = Uri.parse('https://api.navitia.io/v1/coverage/fr-idf/stop_areas/$stopAreaId/departures');
    final http.Response res = await http.get(
      url,
      headers: <String, String>{
        'Authorization': apiKey,
      },
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}


