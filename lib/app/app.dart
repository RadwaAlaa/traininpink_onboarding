import 'package:flutter/material.dart';

/// Root widget. Theme, locales and named routes are wired in Phase 1.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'TrainInPink', home: Scaffold());
  }
}
