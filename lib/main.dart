import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const PlannerApp());
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlannerApp',
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
  final TextEditingController _controller = TextEditingController();
  final List<String> _items = <String>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlannerApp'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final Brightness current = Theme.of(context).brightness;
              final Brightness next = current == Brightness.dark ? Brightness.light : Brightness.dark;
              // This is just a visual demo for the GitHub repo; in a real app you'd lift theme state up.
              final ThemeMode mode = next == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<Widget>(
                  builder: (_) => Theme(
                    data: mode == ThemeMode.dark ? _PlannerTheme.dark() : _PlannerTheme.light(),
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
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Add a task',
                hintText: 'Plan your next step...',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              onSubmitted: (_) => _addCurrent(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _addCurrent,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _items.isEmpty
                  ? _EmptyState(color: colors)
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final String item = _items[index];
                        return Dismissible(
                          key: ValueKey<String>(item + index.toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              color: colors.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.delete, color: colors.onErrorContainer),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => setState(() => _items.removeAt(index)),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(item),
                              leading: const Icon(Icons.check_box_outline_blank),
                              trailing: const Icon(Icons.chevron_right),
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

  void _addCurrent() {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _items.add(text);
      _controller.clear();
    });
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4895EF), brightness: Brightness.dark),
        useMaterial3: true,
      );
}


