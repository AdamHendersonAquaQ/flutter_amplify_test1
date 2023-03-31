import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/pages/dashboardpage.dart';
import 'package:flutter_amplify_test/pages/positionspage.dart';
import 'package:flutter_amplify_test/pages/rawtradespage.dart';
import 'package:flutter_amplify_test/pages/tradespage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trade viewing App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
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
  var selectedIndex = 1;

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
      case 3:
        page = const RawTradesPage();
        break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
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
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_rounded),
                    label: Text('Raw Trades'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
