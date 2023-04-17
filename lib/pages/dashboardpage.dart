import 'package:flutter_amplify_test/pages/pnlpage.dart';
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
      backgroundColor: Theme.of(context).primaryColor,
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
                SizedBox(
                  height: 100,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: PnLPage(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
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
