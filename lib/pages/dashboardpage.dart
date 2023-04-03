import 'package:flutter_amplify_test/pages/positionspage.dart';
import 'package:flutter_amplify_test/pages/tradespage.dart';

import 'package:flutter/material.dart';

import '../shared/colourvariables.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            flex: 35,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: PositionsPage(),
            ),
          ),
          Expanded(
            flex: 65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const <Widget>[
                Expanded(
                  flex: 20,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('PnL', textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  flex: 80,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: TradesPage(),
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
