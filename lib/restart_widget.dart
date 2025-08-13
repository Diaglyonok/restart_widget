import 'package:flutter/material.dart';
import 'package:restart_widget/restart_notifier.dart';

/// A widget that provides app restart functionality.
///
/// This widget wraps your app and provides the ability to restart the entire
/// widget tree with a new session key. It's particularly useful for scenarios
/// where you need to completely reset the app state, such as user logout,
/// theme changes, language switches, or complete app resets.
///
/// The widget uses a [RestartNotifier] to manage the restart state and
/// automatically rebuilds the widget tree when a restart is triggered.
///
/// Example usage:
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return RestartWidget(
///       onSetup: (notifier, {bool reset = false}) async {
///         if (reset) {
///           // Clear app state, caches, preferences, etc.
///           await clearUserData();
///         }
///         // Initialize app state
///         await initializeApp();
///       },
///       builder: (context) => MaterialApp(
///         title: 'My App',
///         home: MyHomePage(),
///       ),
///     );
///   }
/// }
/// ```
class RestartWidget extends StatefulWidget {
  /// Creates a new restart widget.
  ///
  /// The [builder] function returns the widget tree to be displayed,
  /// and the [onSetup] callback is called during initialization and restart.
  const RestartWidget(
      {super.key, required this.builder, required this.onSetup});

  /// A function that returns the widget tree to be displayed.
  ///
  /// This function is called to build the main widget tree of your app.
  /// It receives the current [BuildContext] and should return the root
  /// widget of your application (typically a [MaterialApp] or [CupertinoApp]).
  final Widget Function(BuildContext context) builder;

  /// A callback function called during initialization and restart.
  ///
  /// This function is invoked:
  /// - During initial widget setup (with `reset: false`)
  /// - During restart operations (with `reset: true`)
  ///
  /// Use this callback to:
  /// - Initialize app state, services, and dependencies
  /// - Clear caches, preferences, and user data when restarting
  /// - Reset dependency injection containers
  /// - Perform any other setup or cleanup operations
  ///
  /// The callback receives the [RestartNotifier] instance, which can be used
  /// to trigger additional restarts if needed.
  final Future<void> Function(RestartNotifier cubit, {bool reset}) onSetup;

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

/// The state for the [RestartWidget].
///
/// This state manages the [RestartNotifier] instance and handles the
/// widget lifecycle, including initialization and disposal of the notifier.
class _RestartWidgetState extends State<RestartWidget> {
  /// The restart notifier that manages the app restart functionality.
  late RestartNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = RestartNotifier(onSetup: widget.onSetup);
    widget.onSetup(notifier);
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, child) {
        return Container(
          key: notifier.state.appSessionKey,
          child: widget.builder(context),
        );
      },
    );
  }
}
