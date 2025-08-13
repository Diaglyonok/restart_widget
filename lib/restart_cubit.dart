import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class RestartBaseState {
  const RestartBaseState(this.appSessionKey);
  final Key appSessionKey;
}

class RestartState extends RestartBaseState {
  const RestartState(super.appSessionKey);
}

class RestartNotifier extends ChangeNotifier {
  RestartNotifier({required this.onSetup}) : _state = const RestartState(Key('initial'));

  final void Function(RestartNotifier notifier, {bool reset}) onSetup;
  RestartBaseState _state;

  RestartBaseState get state => _state;

  void restart(Key appSessionKey) {
    onSetup(this, reset: true);
    _state = RestartState(appSessionKey);
    notifyListeners();
  }
}
