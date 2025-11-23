import 'package:flutter/material.dart';
import '../services/geocoding_service.dart';
import '../services/open_trip_map_service.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationResult> _results = <LocationResult>[];
  bool _isSearching = false;
  LocationResult? _selectedLocation;
  List<Map<String, dynamic>> _nearbyPlaces = <Map<String, dynamic>>[];
  bool _loadingPlaces = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = <LocationResult>[];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final List<LocationResult> results =
        await GeocodingService.instance.searchLocation(query);

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  void _selectLocation(LocationResult location) {
    setState(() {
      _selectedLocation = location;
      _nearbyPlaces = <Map<String, dynamic>>[];
    });
    _loadNearbyPlaces(location.latitude, location.longitude);
  }

  Future<void> _loadNearbyPlaces(double lat, double lon) async {
    setState(() {
      _loadingPlaces = true;
    });

    // Get API key from environment or use empty string
    const String apiKey =
        String.fromEnvironment('OPENTRIPMAP_API_KEY', defaultValue: '');
    if (apiKey.isNotEmpty) {
      final OpenTripMapService service = OpenTripMapService(apiKey: apiKey);
      final List<Map<String, dynamic>> places = await service.searchPlaces(
        lat: lat,
        lon: lon,
        radiusMeters: 5000,
        limit: 10,
      );
      setState(() {
        _nearbyPlaces = places;
        _loadingPlaces = false;
      });
    } else {
      setState(() {
        _loadingPlaces = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        actions: <Widget>[
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedLocation);
              },
              child: const Text('Add'),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search location',
                hintText: 'e.g., Paris, Eiffel Tower',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _results = <LocationResult>[];
                              });
                            },
                          )
                        : null,
              ),
              onChanged: _searchLocation,
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                // Search results list
                Expanded(
                  flex: 1,
                  child: _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.location_on,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'Search for a location',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter a place name to search',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (BuildContext context, int index) {
                            final LocationResult location = _results[index];
                            final bool isSelected =
                                _selectedLocation?.name == location.name;
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              title: Text(location.shortName),
                              subtitle: Text(
                                location.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected: isSelected,
                              onTap: () => _selectLocation(location),
                            );
                          },
                        ),
                ),
                // Nearby places or location info
                Expanded(
                  flex: 1,
                  child: _selectedLocation == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.map,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'Select a location',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose from search results to see nearby places',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _selectedLocation!.shortName,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nearby Places',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _loadingPlaces
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _nearbyPlaces.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No nearby places found\n(API key needed for OpenTripMap)',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          itemCount: _nearbyPlaces.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final Map<String, dynamic> place =
                                                _nearbyPlaces[index];
                                            final Map<String, dynamic>?
                                                properties = place['properties']
                                                    as Map<String, dynamic>?;
                                            final String name =
                                                properties?['name']
                                                        as String? ??
                                                    'Unknown';
                                            final String? kinds =
                                                properties?['kinds'] as String?;
                                            return Card(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: ListTile(
                                                leading:
                                                    const Icon(Icons.place),
                                                title: Text(name),
                                                subtitle: kinds != null
                                                    ? Text(
                                                        kinds.split(',').first)
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
