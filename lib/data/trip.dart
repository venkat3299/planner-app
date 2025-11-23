import 'dart:convert';

class ItineraryItem {
  ItineraryItem({
    required this.id,
    required this.title,
    this.latitude,
    this.longitude,
    this.address,
  });
  final String id;
  final String title;
  final double? latitude;
  final double? longitude;
  final String? address;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
      };
  static ItineraryItem fromJson(Map<String, dynamic> json) => ItineraryItem(
        id: json['id'] as String,
        title: json['title'] as String,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        address: json['address'] as String?,
      );
}

class Trip {
  Trip({
    required this.id,
    required this.name,
    this.itinerary = const <ItineraryItem>[],
  });

  final String id;
  final String name;
  final List<ItineraryItem> itinerary;

  Trip copyWith({String? id, String? name, List<ItineraryItem>? itinerary}) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      itinerary: itinerary ?? this.itinerary,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'itinerary': itinerary.map((ItineraryItem e) => e.toJson()).toList(),
      };

  static Trip fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String,
      itinerary: (json['itinerary'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              ItineraryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String encodeList(List<Trip> trips) =>
      jsonEncode(trips.map((Trip t) => t.toJson()).toList());

  static List<Trip> decodeList(String source) {
    final List<dynamic> list = jsonDecode(source) as List<dynamic>;
    return list.map((dynamic e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
  }
}


