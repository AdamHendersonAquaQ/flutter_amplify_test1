import 'package:praxis_internals/pages/dashboard/dashboard_components/dashboard_pnl/charts/pnl_charts_dash.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/dashboard_pnl/figures/pnl_dash.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/positions_dash.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/shared.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/trades_dash.dart';

import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget? drawer;
  void _openEndDrawer(Widget widget) {
    setState(() {
      drawer = widget;
    });
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 40,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
              child: PositionsDash(
                openDrawer: _openEndDrawer,
              ),
            ),
          ),
          Expanded(
            flex: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 10, 10, 5),
                    child: Scaffold(
                      body: Column(
                        children: [
                          const Expanded(child: PnLChartsDash()),
                          noPadDivider,
                          Container(
                            constraints: const BoxConstraints(minHeight: 35),
                            child: const PnLDash(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 10, 10),
                    child: TradesDash(
                      openDrawer: _openEndDrawer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                        onPressed: _closeEndDrawer,
                        icon: const Icon(Icons.close))
                  ],
                ),
              ),
              noPadDivider,
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: drawer ?? const Text(""),
              ),
            ],
          ),
        ),
      ),
      endDrawerEnableOpenDragGesture: false,
    );
  }
}
