import 'package:flutter_amplify_test/pages/positionspage.dart';
import 'package:flutter_amplify_test/pages/tradespage.dart';

import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 35,
            child: Container(
              color: Colors.blue,
              child: const PositionsPage(),
            ),
          ),
          Expanded(
            flex: 65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 20,
                  child: Container(
                    color: Colors.red,
                    child: const Text('PnL', textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  flex: 80,
                  child: Container(
                    color: Colors.green,
                    child: const TradesPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
