import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:restart_widget/restart_cubit.dart';
import 'package:restart_widget/restart_widget.dart';

void main() {
  runApp(const MyApp());
}

diSetup(RestartNotifier cubit) {
  GetIt.I.registerSingleton<UserRepository>(UserRepository(cubit));
}

class UserRepository {
  UserRepository(this.restartCubit);

  final RestartNotifier restartCubit;

  void logout() {
    restartCubit.restart();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      onSetup: (cubit, {bool reset = false}) async {
        if (reset) {
          await GetIt.I.reset();
        }

        diSetup(cubit);
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

            SizedBox(height: 10),

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
