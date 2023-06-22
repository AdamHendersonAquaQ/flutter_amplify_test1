import 'dart:async';
import 'dart:convert';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';

import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/subtitle.dart';
import 'package:praxis_internals/classes/pnl2.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/pnl_chart_daily.dart';

class PnLDailyPage extends StatefulWidget {
  const PnLDailyPage({super.key});

  @override
  State<PnLDailyPage> createState() => _PnLDailyState();
}

class _PnLDailyState extends State<PnLDailyPage> {
  bool runStream = false;
  @override
  void initState() {
    runStream = true;
    super.initState();
  }

  @override
  void dispose() {
    runStream = false;
    super.dispose();
  }

  DateTime lastUpdated = DateTime.now();
  List<PnL2>? data;
  var logger = Logger();

  Stream<List<PnL2>> pnlStream() async* {
    while (runStream) {
      DateTime date = DateTime.now();
      String url =
          "${EnvConfig.restUrl}/pnl2/?date=${date.year}-${date.month}-${date.day}";
      try {
        final response = await NewClient.client!.get(Uri.parse(url));

        var responseData = json.decode(response.body);

        List<PnL2>? pnls = [];
        for (var pnl in responseData) {
          if (pnl["pnl_change"] != null) {
            PnL2 newPnL = PnL2(
                eventTime: DateTime.parse(pnl["event_time"]).toLocal(),
                pnlChange: pnl["pnl_change"]);
            pnls.add(newPnL);
          }
        }
        lastUpdated = DateTime.now();
        data = pnls;
      } catch (e) {
        data = data ?? [];
        logger.e("Error retrieving Positions data from url: $url, retrying.");
      }

      yield data!;
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: pnlStream(),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Daily Profit and Loss (${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/dailypnl');
                        },
                      )
                    ],
                  ),
                  LastUpdatedLabel(
                    lastUpdated: lastUpdated,
                    timeGap: 120,
                  ),
                ],
              ),
            ),
            data != null
                ? Expanded(
                    child: data!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 20, 5),
                            child: PnLDailyChart(
                              data: data!,
                              isDashboard: true,
                            ),
                          )
                        : const Center(
                            child: Text("No data available for this date")),
                  )
                : const Expanded(
                    child: Center(
                    child: CircularProgressIndicator(),
                  )),
          ],
        );
      },
    );
  }
}
