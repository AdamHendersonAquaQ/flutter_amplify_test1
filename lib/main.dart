import 'package:flutter/material.dart';
import 'package:praxis_internals/classes/praxis_service.dart';
import 'package:praxis_internals/main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PraxisService.configure("prod");

  runApp(const MyApp());
}
