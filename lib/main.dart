import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create(
    deviceLocale: binding.platformDispatcher.locale,
  );
  runApp(App(dependencies: dependencies));
}
