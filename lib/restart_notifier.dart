import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Base state class for restart functionality.
///
/// This abstract class provides the foundation for managing app session keys
/// during restart operations. It ensures that all restart states have
/// a consistent structure with an associated session key.
@immutable
abstract class RestartBaseState {
  /// Creates a new restart base state with the given session key.
  ///
  /// The [appSessionKey] is used to force Flutter to rebuild the widget tree
  /// when the app is restarted.
  const RestartBaseState(this.appSessionKey);

  /// The session key associated with this restart state.
  ///
  /// This key is used to force Flutter to completely rebuild the widget tree,
  /// effectively "restarting" the app with a clean state.
  final Key appSessionKey;
}

/// Concrete implementation of restart state.
///
/// This class represents a specific restart state with an associated session key.
/// It extends [RestartBaseState] to provide the actual state implementation
/// used by the [RestartNotifier].
class RestartState extends RestartBaseState {
  /// Creates a new restart state with the given session key.
  ///
  /// The [appSessionKey] will be used to trigger widget tree reconstruction.
  const RestartState(super.appSessionKey);
}

/// A ChangeNotifier that manages app restart functionality.
///
/// This class provides a simple way to restart your Flutter app's widget tree
/// by changing the session key, which forces Flutter to completely rebuild
/// the widget hierarchy. This is useful for scenarios like user logout,
/// theme changes, language switches, or complete app state resets.
///
/// Example usage:
/// ```dart
/// final notifier = RestartNotifier(onSetup: (notifier, {reset}) async {
///   if (reset) {
///     // Clear app state
///     await clearUserData();
///   }
/// });
///
/// // Restart the app with auto-generated key
/// notifier.restart();
///
/// // Or restart with custom key
/// notifier.restart(Key('custom_session_key'));
/// ```
class RestartNotifier extends ChangeNotifier {
  /// Creates a new restart notifier with the given setup callback.
  ///
  /// The [onSetup] callback is called during initialization and each time
  /// the app is restarted. It receives the notifier instance and a boolean
  /// indicating whether this is a restart operation.
  RestartNotifier({required this.onSetup}) : _state = const RestartState(Key('initial'));

  /// Callback function called during initialization and restart.
  ///
  /// This function is invoked:
  /// - During initial setup (with `reset: false`)
  /// - During restart operations (with `reset: true`)
  ///
  /// Use this callback to initialize app state, clear caches, reset
  /// preferences, or perform any other setup/cleanup operations.
  final void Function(RestartNotifier notifier, {bool reset}) onSetup;

  /// The current restart state.
  RestartBaseState _state;

  /// Gets the current restart state.
  ///
  /// This state contains the current session key used by the widget tree.
  RestartBaseState get state => _state;

  /// Restarts the app with a new session key.
  ///
  /// This method triggers a complete app restart by:
  /// 1. Calling the [onSetup] callback with `reset: true`
  /// 2. Creating a new [RestartState] with the provided or auto-generated [appSessionKey]
  /// 3. Notifying listeners to rebuild the widget tree
  ///
  /// If [appSessionKey] is not provided, a timestamp-based key will be
  /// automatically generated using `DateTime.now().millisecondsSinceEpoch`.
  ///
  /// Common patterns for custom session keys:
  /// - Timestamp-based keys: `Key('session_${DateTime.now().millisecondsSinceEpoch}')`
  /// - Random keys: `Key(Random().nextInt(10000).toString())`
  /// - UUID keys: `Key(Uuid().v4())`
  ///
  /// Examples:
  /// ```dart
  /// // Auto-generated key
  /// notifier.restart();
  ///
  /// // Custom key
  /// notifier.restart(Key('restart_${DateTime.now().millisecondsSinceEpoch}'));
  /// ```
  void restart([Key? appSessionKey]) {
    onSetup(this, reset: true);
    _state = RestartState(appSessionKey ?? Key(DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }
}
