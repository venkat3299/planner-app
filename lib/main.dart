import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/trip.dart';
import 'data/trip_store.dart';
import 'services/notifications_service.dart';
import 'screens/location_search_screen.dart';
import 'services/geocoding_service.dart';
import 'services/navitia_service.dart';
import 'services/amadeus_service.dart';
import 'services/open_meteo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsService.instance.init();
  runApp(const PlannerApp());
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Planner',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
      ],
      home: const _HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const Color seed = Color(0xFF3F37C9);
    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const Color seed = Color(0xFF4895EF);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  List<Trip> _trips = <Trip>[];
  SharedPreferences? _prefs;
  TripStore? _store;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final TripStore store = TripStore(p);
    final List<Trip> saved = store.load();
    setState(() {
      _prefs = p;
      _store = store;
      _trips = saved;
    });
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planner'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Test notification now',
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              NotificationsService.instance.showNow(
                title: 'Trip Planner',
                body: 'Test notification - working!',
              );
            },
          ),
          IconButton(
            tooltip: 'Notify in 10s',
            icon: const Icon(Icons.notifications),
            onPressed: () {
              NotificationsService.instance.scheduleInSeconds(
                title: 'Trip Planner',
                body: 'Scheduled notification in 10 seconds',
                seconds: 10,
              );
            },
          ),
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              final Brightness current = Theme.of(context).brightness;
              final Brightness next = current == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark;
              // This is just a visual demo for the GitHub repo; in a real app you'd lift theme state up.
              final ThemeMode mode =
                  next == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<Widget>(
                  builder: (_) => Theme(
                    data: mode == ThemeMode.dark
                        ? _PlannerTheme.dark()
                        : _PlannerTheme.light(),
                    child: const _HomeScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _tripNameController,
                    decoration: const InputDecoration(
                      labelText: 'Add a trip',
                      hintText: 'e.g., Goa Weekend',
                      prefixIcon: Icon(Icons.flight_takeoff),
                    ),
                    onSubmitted: (_) => _addTrip(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addTrip,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _trips.isEmpty
                  ? _EmptyState(color: colors)
                  : ListView.separated(
                      itemCount: _trips.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Trip trip = _trips[index];
                        return Dismissible(
                          key: ValueKey<String>(trip.id),
                          background: Container(
                            decoration: BoxDecoration(
                              color: colors.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.delete,
                                color: colors.onErrorContainer),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTrip(trip),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(trip.name),
                              leading: const Icon(Icons.trip_origin),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openTrip(context, trip),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _persist() async {
    final TripStore? s = _store;
    if (s == null) return;
    await s.save(_trips);
  }

  Future<void> _addTrip() async {
    final String name = _tripNameController.text.trim();
    if (name.isEmpty) return;
    final Trip trip = Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    setState(() {
      _trips = <Trip>[trip, ..._trips];
      _tripNameController.clear();
    });
    await _persist();
    // Notification: Trip added successfully
    NotificationsService.instance.showNow(
      title: 'Trip Added',
      body: 'Your trip "$name" has been added!',
    );
  }

  Future<void> _deleteTrip(Trip trip) async {
    setState(() {
      _trips = _trips.where((Trip t) => t.id != trip.id).toList();
    });
    await _persist();
    // Notification: Trip deleted
    NotificationsService.instance.showNow(
      title: 'Trip Deleted',
      body: 'Trip "${trip.name}" has been removed.',
    );
  }

  Future<void> _openTrip(BuildContext context, Trip trip) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _TripDetails(
        trip: trip,
        onSave: (Trip updated) async {
          setState(() {
            _trips =
                _trips.map((Trip t) => t.id == updated.id ? updated : t).toList();
          });
          await _persist();
        },
      ),
    ));
  }
}

class _TripDetails extends StatefulWidget {
  const _TripDetails({required this.trip, required this.onSave});
  final Trip trip;
  final Future<void> Function(Trip) onSave;

  @override
  State<_TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<_TripDetails> {
  late Trip _trip;
  final TextEditingController _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'bus') {
                _showBusSearch(context);
              } else if (value == 'flight') {
                _showFlightSearch(context);
              } else if (value == 'weather') {
                _showWeatherForTrip(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'bus',
                child: ListTile(
                  leading: Icon(Icons.directions_bus),
                  title: Text('Search Bus/Transit'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'flight',
                child: ListTile(
                  leading: Icon(Icons.flight),
                  title: Text('Search Flights'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'weather',
                child: ListTile(
                  leading: Icon(Icons.wb_sunny),
                  title: Text('Weather Forecast'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Add itinerary item',
                      hintText: 'e.g., Visit Fort Aguada',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Search location on map',
                  icon: const Icon(Icons.map),
                  onPressed: () => _searchLocation(),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _trip.itinerary.isEmpty
                  ? _EmptyState(color: colors)
                  : ListView.separated(
                      itemCount: _trip.itinerary.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final ItineraryItem item = _trip.itinerary[index];
                        return Dismissible(
                          key: ValueKey<String>(item.id),
                          background: Container(
                            decoration: BoxDecoration(
                              color: colors.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.delete,
                                color: colors.onErrorContainer),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _removeItem(item),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: item.address != null ? Text(item.address!) : null,
                              leading: Icon(
                                item.latitude != null && item.longitude != null
                                    ? Icons.location_on
                                    : Icons.place,
                                color: item.latitude != null && item.longitude != null
                                    ? colors.primary
                                    : null,
                              ),
                              trailing: item.latitude != null && item.longitude != null
                                  ? IconButton(
                                      icon: const Icon(Icons.map),
                                      tooltip: 'View on map',
                                      onPressed: () => _showLocationOnMap(context, item),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchLocation() async {
    final LocationResult? result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute<LocationResult>(
        builder: (_) => const LocationSearchScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _trip = _trip.copyWith(
          itinerary: <ItineraryItem>[
            ItineraryItem(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: result.shortName,
              latitude: result.latitude,
              longitude: result.longitude,
              address: result.name,
            ),
            ..._trip.itinerary,
          ],
        );
      });
      await widget.onSave(_trip);
      // Notification: Location added
      NotificationsService.instance.showNow(
        title: 'Location Added',
        body: 'Added "${result.shortName}" to ${_trip.name}',
      );
    }
  }

  Future<void> _addItem() async {
    final String title = _itemController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _trip = _trip.copyWith(
        itinerary: <ItineraryItem>[
          ItineraryItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
          ),
          ..._trip.itinerary,
        ],
      );
      _itemController.clear();
    });
    await widget.onSave(_trip);
    // Notification: Itinerary item added
    NotificationsService.instance.showNow(
      title: 'Item Added',
      body: 'Added "$title" to ${_trip.name}',
    );
  }

  Future<void> _showLocationOnMap(BuildContext context, ItineraryItem item) async {
    if (item.latitude == null || item.longitude == null) return;
    
    // Show weather and location info
    final OpenMeteoService weatherService = OpenMeteoService();
    final Map<String, dynamic>? weather = await weatherService.getDailyForecast(
      lat: item.latitude!,
      lon: item.longitude!,
    );
    
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: <Widget>[
              AppBar(
                title: Text(item.title),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (item.address != null) ...[
                        Text('Address', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(item.address!),
                        const SizedBox(height: 16),
                      ],
                      Text('Coordinates', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Lat: ${item.latitude!.toStringAsFixed(4)}, Lon: ${item.longitude!.toStringAsFixed(4)}'),
                      const SizedBox(height: 16),
                      if (weather != null) ...[
                        Text('Weather Forecast', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _buildWeatherCard(context, weather),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, Map<String, dynamic> weather) {
    final Map<String, dynamic>? daily = weather['daily'] as Map<String, dynamic>?;
    if (daily == null) return const SizedBox.shrink();
    
    final List<dynamic>? dates = daily['time'] as List<dynamic>?;
    final List<dynamic>? maxTemps = daily['temperature_2m_max'] as List<dynamic>?;
    final List<dynamic>? minTemps = daily['temperature_2m_min'] as List<dynamic>?;
    
    if (dates == null || maxTemps == null || minTemps == null || dates.isEmpty) {
      return const Text('No weather data available');
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < dates.length && i < 3; i++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(dates[i] as String? ?? ''),
                  Text('${maxTemps[i]}° / ${minTemps[i]}°'),
                ],
              ),
              if (i < dates.length - 1 && i < 2) const Divider(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showBusSearch(BuildContext context) async {
    final TextEditingController stopController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Search Bus/Transit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: stopController,
              decoration: const InputDecoration(
                labelText: 'Stop Area ID',
                hintText: 'e.g., stop_area:SNCF:87113001',
                helperText: 'Get from navitia.io',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Requires Navitia API key. Get free key from navitia.io',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final String stopId = stopController.text.trim();
              if (stopId.isEmpty) return;
              
              final String? apiKey = const String.fromEnvironment('NAVITIA_API_KEY', defaultValue: '');
              if (apiKey == null || apiKey.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navitia API key required. Set NAVITIA_API_KEY')),
                );
                return;
              }
              
              final NavitiaService service = NavitiaService(apiKey: apiKey);
              final Map<String, dynamic>? departures = await service.getDepartures(stopId);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                _showBusResults(context, departures);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showBusResults(BuildContext context, Map<String, dynamic>? departures) {
    if (departures == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No departures found or API error')),
      );
      return;
    }
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Bus Departures'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              departures.toString(),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFlightSearch(BuildContext context) async {
    final TextEditingController originController = TextEditingController();
    final TextEditingController destController = TextEditingController();
    final TextEditingController dateController = TextEditingController(
      text: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0],
    );
    
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Search Flights'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: 'Origin (IATA code)',
                hintText: 'e.g., PAR',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: destController,
              decoration: const InputDecoration(
                labelText: 'Destination (IATA code)',
                hintText: 'e.g., NYC',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Departure Date',
                hintText: 'YYYY-MM-DD',
                helperText: 'Format: YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Requires Amadeus API keys (sandbox available)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final String origin = originController.text.trim().toUpperCase();
              final String dest = destController.text.trim().toUpperCase();
              final String date = dateController.text.trim();
              
              if (origin.isEmpty || dest.isEmpty || date.isEmpty) return;
              
              final String? clientId = const String.fromEnvironment('AMADEUS_CLIENT_ID', defaultValue: '');
              final String? clientSecret = const String.fromEnvironment('AMADEUS_CLIENT_SECRET', defaultValue: '');
              
              if (clientId == null || clientId.isEmpty || clientSecret == null || clientSecret.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Amadeus API keys required. Set AMADEUS_CLIENT_ID and AMADEUS_CLIENT_SECRET')),
                );
                return;
              }
              
              final AmadeusService service = AmadeusService(clientId: clientId, clientSecret: clientSecret);
              final Map<String, dynamic>? flights = await service.searchFlights(
                origin: origin,
                destination: dest,
                departureDate: date,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                _showFlightResults(context, flights);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFlightResults(BuildContext context, Map<String, dynamic>? flights) {
    if (flights == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flights found or API error')),
      );
      return;
    }
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Flight Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              flights.toString(),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWeatherForTrip(BuildContext context) async {
    if (_trip.itinerary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add locations to your trip to see weather')),
      );
      return;
    }
    
    final List<ItineraryItem> locationsWithCoords = _trip.itinerary
        .where((ItineraryItem item) => item.latitude != null && item.longitude != null)
        .toList();
    
    if (locationsWithCoords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No locations with coordinates found')),
      );
      return;
    }
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Weather Forecast'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: FutureBuilder<Map<String, Map<String, dynamic>?>>(
            future: _loadWeatherForLocations(locationsWithCoords),
            builder: (BuildContext context, AsyncSnapshot<Map<String, Map<String, dynamic>?>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData) {
                return const Center(child: Text('Failed to load weather'));
              }
              
              return ListView.builder(
                itemCount: locationsWithCoords.length,
                itemBuilder: (BuildContext context, int index) {
                  final ItineraryItem item = locationsWithCoords[index];
                  final Map<String, dynamic>? weather = snapshot.data![item.id];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: weather != null
                          ? _buildWeatherSummary(weather)
                          : const Text('Weather data unavailable'),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, Map<String, dynamic>?>> _loadWeatherForLocations(List<ItineraryItem> locations) async {
    final OpenMeteoService service = OpenMeteoService();
    final Map<String, Map<String, dynamic>?> results = <String, Map<String, dynamic>?>{};
    
    for (final ItineraryItem item in locations) {
      if (item.latitude != null && item.longitude != null) {
        final Map<String, dynamic>? weather = await service.getDailyForecast(
          lat: item.latitude!,
          lon: item.longitude!,
        );
        results[item.id] = weather;
      }
    }
    
    return results;
  }

  Widget _buildWeatherSummary(Map<String, dynamic> weather) {
    final Map<String, dynamic>? daily = weather['daily'] as Map<String, dynamic>?;
    if (daily == null) return const Text('No data');
    
    final List<dynamic>? maxTemps = daily['temperature_2m_max'] as List<dynamic>?;
    if (maxTemps == null || maxTemps.isEmpty) return const Text('No data');
    
    return Text('Today: ${maxTemps[0]}°C');
  }

  Future<void> _removeItem(ItineraryItem item) async {
    setState(() {
      _trip = _trip.copyWith(
        itinerary:
            _trip.itinerary.where((ItineraryItem e) => e.id != item.id).toList(),
      );
    });
    await widget.onSave(_trip);
    // Notification: Itinerary item removed
    NotificationsService.instance.showNow(
      title: 'Item Removed',
      body: 'Removed "${item.title}" from ${_trip.name}',
    );
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color});

  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.calendar_month_outlined, size: 64, color: color.primary),
          const SizedBox(height: 12),
          Text(
            'Plan your day',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add tasks to get started.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PlannerTheme {
  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F37C9)),
        useMaterial3: true,
      );
  static ThemeData dark() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4895EF), brightness: Brightness.dark),
        useMaterial3: true,
      );
}
