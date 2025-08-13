import 'package:flutter/material.dart';
import 'package:restart_widget/restart_cubit.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.builder, required this.onSetup});
  final Widget Function(BuildContext context) builder;
  final Future<void> Function(RestartNotifier cubit, {bool reset}) onSetup;

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  late RestartNotifier notifier;
  @override
  void initState() {
    notifier = RestartNotifier(onSetup: widget.onSetup);
    widget.onSetup(notifier);
    super.initState();
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
