import 'package:flutter/material.dart';
import 'package:praxis_internals/authentication/authentication_service.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/main.dart';

class NavRail extends StatefulWidget {
  const NavRail({super.key, required this.page, required this.index});
  final Widget page;
  final int index;
  @override
  State<NavRail> createState() => _NavRailState();
}

final List<String> destinations = [
  "dashboard",
  "positions",
  "dailypnl",
  "trades",
];

class _NavRailState extends State<NavRail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrey,
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_mosaic_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_rounded),
                  label: Text('Positions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_graph),
                  label: Text('PnL'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.currency_exchange_rounded),
                  label: Text('Trades'),
                ),
              ],
              selectedIndex: widget.index,
              onDestinationSelected: (value) {
                Navigator.of(context)
                    .pushReplacementNamed("/${destinations[value]}");
              },
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/praxis_logo.png',
                  //package: "praxis_internals",
                  width: 50,
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.lightbulb_circle_outlined,
                          size: 35,
                        ),
                        tooltip: "Toggle dark mode",
                        onPressed: () {
                          MyApp.of(context).toggleTheme();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_outlined,
                            size: 35,
                          ),
                          tooltip: "Log out",
                          onPressed: () {
                            AuthenticationService.signOutCurrentUser();
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).primaryColor,
              child: widget.page,
            ),
          ),
        ],
      ),
    );
  }
}
