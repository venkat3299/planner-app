## PlannerApp

A modern planning app built with Flutter.



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

### Project structure

```
lib/
  main.dart         # app entry, theming, and simple home screen
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


