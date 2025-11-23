## Trip Planner

A simple trip planning app built with Flutter. Create trips and add itinerary items. Data is stored locally using SharedPreferences.



[![Flutter CI](https://github.com/venkat3299/planner-app/actions/workflows/flutter.yaml/badge.svg)](https://github.com/venkat3299/planner-app/actions/workflows/flutter.yaml)

### What’s inside

- **Flutter + Material 3** with light/dark themes
- Strict **lints** via `flutter_lints`
- **GitHub Actions**: format, analyze, and tests on push/PR
- Friendly **README**, **MIT License**, **Code of Conduct**, **Contributing**, and issue templates

### Getting started

Prerequisites:
- Flutter SDK (`stable` channel). See Flutter install guide.

Install dependencies:

```bash
flutter pub get
```

Run the app (pick your platform):

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d ios
flutter run -d android
```

If you don’t have platform folders yet (e.g., `ios/`, `android/`, `macos/`, `web/`), Flutter will generate them for you when you run on that platform. You can also regenerate with:

```bash
flutter create .
```

### Scripts

```bash
dart format .                # format
flutter analyze               # static analysis
flutter test --coverage       # run tests with coverage
```

### API keys and configuration

This app can use free-tier APIs. Provide keys via `--dart-define` at run time:

```bash
flutter run \
  --dart-define=OPENTRIPMAP_API_KEY=your_key \
  --dart-define=NAVITIA_API_KEY=your_key \
  --dart-define=AMADEUS_CLIENT_ID=your_id \
  --dart-define=AMADEUS_CLIENT_SECRET=your_secret
```

CI: Add these as GitHub Actions secrets and pass with `flutter run`/`flutter test` steps if needed.

### Services (free tiers)

- Open-Meteo (no key): simple daily forecast
- OpenTripMap (key): nearby POIs
- Navitia (key, best EU): departures for bus/train
- Amadeus sandbox (keys): flight offers search

### Project structure

```
lib/
  main.dart         # app entry, theming, Trips list and Trip Details
  data/
    trip.dart       # Trip + ItineraryItem models with JSON helpers
    trip_store.dart # SharedPreferences storage for trips
test/
  widget_test.dart  # basic smoke test
```

### CI

GitHub Actions (`.github/workflows/flutter.yaml`) runs on push and PR:

- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test --coverage`

### Contributing

Please read `CONTRIBUTING.md` and follow the Code of Conduct. Use conventional commits if possible (e.g., `feat:`, `fix:`, `docs:`).

### License

MIT © 2025 Venkat Gandhasri


