import 'package:flutter/material.dart';
import 'package:praxis_internals/classes/praxis_service.dart';
import 'package:praxis_internals/pages/auth/auth_page.dart';
import 'package:praxis_internals/pages/auth/auth_frame.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_page.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart_page.dart';
import 'package:praxis_internals/pages/positions/positions_page.dart';
import 'package:praxis_internals/pages/trades/trades_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PraxisService.configure("dev");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praxis RISK Dashboard',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlue, background: offWhite),
          primaryColor: const Color.fromARGB(255, 179, 179, 179),
          scaffoldBackgroundColor: const Color.fromARGB(255, 228, 228, 230)),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
          primaryColor: darkGrey,
          scaffoldBackgroundColor: const Color.fromARGB(255, 42, 46, 48)),
      themeMode: _themeMode,
      home: const AuthPage(),
      routes: <String, WidgetBuilder>{
        '/dashboard': (BuildContext context) => const AuthFrame(
              page: DashboardPage(),
              index: 0,
            ),
        '/positions': (BuildContext context) =>
            const AuthFrame(page: PositionsPage(), index: 1),
        '/dailypnl': (BuildContext context) =>
            const AuthFrame(page: PnLChartPage(), index: 2),
        '/trades': (BuildContext context) => const AuthFrame(
              page: TradesPage(),
              index: 3,
            ),
      },
    );
  }
}
