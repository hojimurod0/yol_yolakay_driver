import 'package:flutter/material.dart';

import 'core/services/app_initializer.dart';
import 'driver_app.dart';

/// Main entry point for the Yo'l-Yo'lakay Driver application.
Future<void> main() async {
  await AppInitializer.init();
  runApp(const YolYolakayDriverApp());
}
