# restart_widget

A Flutter package that provides a simple way to restart your app's widget tree with a new session key. This is particularly useful for scenarios where you need to completely reset the app state, such as user logout, theme changes, or language switches.

## Features

- 🔄 **Easy App Restart**: Restart your entire widget tree with a single method call
- 🎯 **State Management**: Built on top of ChangeNotifier for simple state management
- 🔑 **Session Keys**: Each restart gets a unique session key for proper widget tree reconstruction
- 🧹 **Automatic Cleanup**: Proper disposal of resources when widgets are unmounted
- ⚡ **Lightweight**: Minimal overhead with no external dependencies beyond Flutter core

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  restart_widget:
    git:
      url: https://github.com/yourusername/restart_widget.git
```

### Usage

#### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:restart_widget/restart_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      onSetup: (notifier, {bool reset = false}) async {
        // Initialize your app state here
        if (reset) {
          // Handle reset logic (clear caches, reset preferences, etc.)
          print('App is restarting...');
        }
      },
      builder: (context) => MaterialApp(
        title: 'My App',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Get the notifier and restart the app
            final notifier = context.findAncestorStateOfType<_RestartWidgetState>()!.notifier;
            notifier.restart(Key('new_session_${DateTime.now().millisecondsSinceEpoch}'));
          },
          child: Text('Restart App'),
        ),
      ),
    );
  }
}
```

#### Advanced Example with Dependency Injection (GetIt)

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:restart_widget/restart_widget.dart';

void main() {
  runApp(const MyApp());
}

// Setup dependency injection
void diSetup(RestartNotifier notifier) {
  GetIt.I.registerSingleton<UserRepository>(UserRepository(notifier));
}

class UserRepository {
  UserRepository(this.restartNotifier);
  final RestartNotifier restartNotifier;

  void logout() {
    restartNotifier.restart(Key(Random().nextInt(1000).toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      onSetup: (notifier, {bool reset = false}) async {
        if (reset) {
          // Reset dependency injection container
          await GetIt.I.reset();
        }
        
        // Setup dependencies
        diSetup(notifier);
      },
      builder: (context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => GetIt.I.get<UserRepository>().logout(),
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### Simple Example with Static Manager

```dart
import 'package:flutter/material.dart';
import 'package:restart_widget/restart_widget.dart';

class AppManager {
  static RestartNotifier? _notifier;
  
  static void initialize(RestartNotifier notifier) {
    _notifier = notifier;
  }
  
  static void restartApp() {
    if (_notifier != null) {
      _notifier!.restart(Key('restart_${DateTime.now().millisecondsSinceEpoch}'));
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      onSetup: (notifier, {bool reset = false}) async {
        AppManager.initialize(notifier);
        
        if (reset) {
          // Clear all app state
          await _clearUserData();
          await _resetPreferences();
          await _clearCaches();
        }
        
        // Initialize app state
        await _loadUserPreferences();
        await _initializeServices();
      },
      builder: (context) => MaterialApp(
        title: 'Advanced App',
        home: HomePage(),
      ),
    );
  }
  
  Future<void> _clearUserData() async {
    // Clear user data logic
  }
  
  Future<void> _resetPreferences() async {
    // Reset preferences logic
  }
  
  Future<void> _clearCaches() async {
    // Clear caches logic
  }
  
  Future<void> _loadUserPreferences() async {
    // Load preferences logic
  }
  
  Future<void> _initializeServices() async {
    // Initialize services logic
  }
}
```

## API Reference

### RestartWidget

A widget that wraps your app and provides restart functionality.

#### Constructor

```dart
RestartWidget({
  Key? key,
  required Widget Function(BuildContext context) builder,
  required Future<void> Function(RestartNotifier notifier, {bool reset}) onSetup,
})
```

#### Parameters

- `builder`: A function that returns the widget tree to be displayed
- `onSetup`: A callback function called during initialization and restart

### RestartNotifier

A ChangeNotifier that manages the restart state.

#### Methods

- `restart(Key appSessionKey)`: Restarts the app with a new session key

#### State

- `RestartBaseState`: Base state containing the current session key
- `RestartState`: Concrete implementation of the restart state

## Use Cases

### User Logout
```dart
void logout() async {
  await _clearUserSession();
  AppManager.restartApp(); // Restarts with clean state
}
```

### Theme Change
```dart
void changeTheme(ThemeMode mode) async {
  await _saveThemePreference(mode);
  AppManager.restartApp(); // Restarts with new theme
}
```

### Language Change
```dart
void changeLanguage(Locale locale) async {
  await _saveLanguagePreference(locale);
  AppManager.restartApp(); // Restarts with new language
}
```

### App Reset
```dart
void resetApp() async {
  await _clearAllData();
  AppManager.restartApp(); // Complete app reset
}
```

## Best Practices

### Dependency Injection Integration

When using dependency injection containers like GetIt, Riverpod, or Provider:

```dart
// Reset DI container on restart
onSetup: (notifier, {bool reset = false}) async {
  if (reset) {
    await GetIt.I.reset(); // or your DI container reset method
  }
  // Re-register dependencies
  setupDependencies(notifier);
}
```

### Session Key Generation

Generate unique session keys for each restart:

```dart
// Using timestamp
notifier.restart(Key('session_${DateTime.now().millisecondsSinceEpoch}'));

// Using random number
notifier.restart(Key(Random().nextInt(10000).toString()));

// Using UUID
notifier.restart(Key(Uuid().v4()));
```

### State Cleanup

Always clean up resources in the `onSetup` callback when `reset: true`:

```dart
onSetup: (notifier, {bool reset = false}) async {
  if (reset) {
    // Clear caches
    await cacheManager.clear();
    // Reset preferences
    await prefs.clear();
    // Dispose services
    await serviceLocator.reset();
  }
}
```

## How It Works

1. **Initialization**: When `RestartWidget` is created, it initializes a `RestartNotifier` and calls the `onSetup` callback
2. **State Management**: The notifier manages the current session key using ChangeNotifier pattern
3. **Restart Process**: When `restart()` is called:
   - The `onSetup` callback is invoked with `reset: true`
   - A new `RestartState` is created with a new session key
   - The widget tree is rebuilt with the new key
4. **Widget Reconstruction**: The new session key forces Flutter to completely rebuild the widget tree, effectively "restarting" the app

## Running the Example

To run the example app:

```bash
cd example
flutter pub get
flutter run
```

The example demonstrates:
- Basic restart functionality
- Integration with GetIt dependency injection
- State management during restarts
- Proper cleanup and re-initialization

## Testing

The package includes comprehensive tests covering all functionality:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
