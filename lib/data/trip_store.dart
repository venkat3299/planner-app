import 'package:shared_preferences/shared_preferences.dart';
import 'trip.dart';

class TripStore {
  TripStore(this._prefs);
  final SharedPreferences _prefs;
  static const String _key = 'trips_v1';

  List<Trip> load() {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <Trip>[];
    return Trip.decodeList(raw);
  }

  Future<void> save(List<Trip> trips) async {
    await _prefs.setString(_key, Trip.encodeList(trips));
  }
}
