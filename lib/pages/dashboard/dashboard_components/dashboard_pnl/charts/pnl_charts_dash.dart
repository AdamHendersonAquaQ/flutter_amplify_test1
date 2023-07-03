import 'package:flutter/material.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/dashboard_pnl/charts/pnl_daily.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/dashboard_pnl/charts/pnl_monthly.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/shared.dart';
import 'package:praxis_internals/pages/pnl/shared.dart';

class PnLChartsDash extends StatefulWidget {
  const PnLChartsDash({super.key});

  @override
  State<PnLChartsDash> createState() => _PnLChartsDashState();
}

class _PnLChartsDashState extends State<PnLChartsDash> {
  int selectedCalender = 0;
  void setSelectedCalender(int cal) {
    setState(() {
      selectedCalender = cal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Profit and Loss (${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: PnLSegmentedButton(
                        selectedCalender: selectedCalender,
                        setSelectedCalender: setSelectedCalender),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/pnl');
                  },
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
          child: noPadDivider,
        ),
        Expanded(
            child: selectedCalender == 0
                ? const PnLDailyPage()
                : const PnLMonthlyPage())
      ],
    );
  }
}
