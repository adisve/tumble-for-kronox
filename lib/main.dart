import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tumble/core/app.dart';
import 'package:tumble/core/shared/app_dependencies.dart';
import 'package:tumble/core/dependency_injection/get_it_instances.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.initialize();
  await getIt<AppDependencies>().initialize();
  runApp(const App());
}
