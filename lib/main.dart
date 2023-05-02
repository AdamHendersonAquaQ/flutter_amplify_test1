import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/pages/dashboardpage.dart';
import 'package:flutter_amplify_test/pages/positionspage.dart';
import 'package:flutter_amplify_test/pages/tradespage.dart';
import 'package:praxis_internals/main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp1 extends StatefulWidget {
  const MyApp1({super.key});

  @override
  State<MyApp1> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp1> {
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
      title: 'Trade viewing App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            background: const Color.fromARGB(255, 224, 226, 226)),
        primaryColor: const Color.fromARGB(255, 169, 171, 172),
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(primaryColor: const Color.fromARGB(255, 85, 85, 85)),
      themeMode: _themeMode,
      home: const MainApp(),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const PositionsPage();
        break;
      case 2:
        page = const TradesPage();
        break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 85, 85, 85),
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_rounded),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_rounded),
                    label: Text('Positions'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_rounded),
                    label: Text('Trades'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
                leading: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    'images/praxis_logo.png',
                    width: 50,
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      icon: const Icon(
                        Icons.lightbulb_circle_outlined,
                        size: 40,
                      ),
                      onPressed: () {
                        MyApp.of(context).toggleTheme();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
