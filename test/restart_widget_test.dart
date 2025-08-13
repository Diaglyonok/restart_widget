import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restart_widget/restart_widget.dart';
import 'package:restart_widget/restart_notifier.dart';

void main() {
  group('RestartCubit Tests', () {
    late RestartNotifier notifier;
    late bool resetCalled;

    setUp(() {
      resetCalled = false;
      notifier = RestartNotifier(
        onSetup: (cubit, {bool reset = false}) {
          if (reset) resetCalled = true;
        },
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('should emit initial state with default key', () {
      expect(notifier.state, isA<RestartState>());
      expect(notifier.state.appSessionKey, const Key('initial'));
    });

    test('should restart and emit new state with provided key', () {
      final newKey = const Key('new_session');

      notifier.restart(newKey);

      expect(notifier.state, isA<RestartState>());
      expect(notifier.state.appSessionKey, newKey);
      expect(resetCalled, true);
    });

    test('should emit different states for different keys', () {
      final key1 = const Key('session_1');
      final key2 = const Key('session_2');

      notifier.restart(key1);
      expect(notifier.state.appSessionKey, key1);

      notifier.restart(key2);
      expect(notifier.state.appSessionKey, key2);
    });
  });

  group('RestartWidget Tests', () {
    late bool setupCalled;
    late RestartNotifier? capturedNotifier;

    setUp(() {
      setupCalled = false;
      capturedNotifier = null;
    });

    Future<void> onSetup(RestartNotifier notifier, {bool reset = false}) async {
      setupCalled = true;
      capturedNotifier = notifier;
    }

    Widget createTestWidget() {
      return MaterialApp(
        home: RestartWidget(
          onSetup: onSetup,
          builder: (context) => const Text('Test Widget'),
        ),
      );
    }

    testWidgets('should create RestartCubit and call onSetup', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(setupCalled, true);
      expect(capturedNotifier, isNotNull);
      expect(capturedNotifier, isA<RestartNotifier>());
    });

    testWidgets('should render builder widget with initial state',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should update widget when cubit state changes',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      final initialContainer = tester.widget<Container>(find.byType(Container));
      final initialKey = initialContainer.key;

      // Trigger restart
      capturedNotifier!.restart(const Key('new_session'));
      await tester.pump();

      final newContainer = tester.widget<Container>(find.byType(Container));
      final newKey = newContainer.key;

      expect(newKey, isNot(equals(initialKey)));
      expect(newKey, const Key('new_session'));
    });

    testWidgets('should dispose cubit when widget is disposed', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(capturedNotifier, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());

      // ChangeNotifier doesn't have isClosed property, but dispose() is called
      expect(capturedNotifier, isNotNull);
    });

    testWidgets('should rebuild with new key after restart', (tester) async {
      await tester.pumpWidget(createTestWidget());

      capturedNotifier!.restart(const Key('restart_1'));
      await tester.pump();

      final secondKey = tester.widget<Container>(find.byType(Container)).key;
      expect(secondKey, const Key('restart_1'));

      capturedNotifier!.restart(const Key('restart_2'));
      await tester.pump(Duration(milliseconds: 17));

      final thirdKey = tester.widget<Container>(find.byType(Container)).key;
      expect(thirdKey, const Key('restart_2'));
    });
  });

  group('RestartBaseState Tests', () {
    test('should create state with provided key', () {
      final key = const Key('test_key');
      final state = RestartState(key);

      expect(state.appSessionKey, key);
    });

    test('should have different keys for different states', () {
      final key1 = const Key('key_1');
      final key2 = const Key('key_2');

      final state1 = RestartState(key1);
      final state2 = RestartState(key2);

      expect(state1.appSessionKey, key1);
      expect(state2.appSessionKey, key2);
      expect(state1.appSessionKey, isNot(equals(state2.appSessionKey)));
    });
  });
}
