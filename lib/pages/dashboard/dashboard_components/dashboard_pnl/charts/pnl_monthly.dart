import 'dart:async';
import 'dart:convert';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';

import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:praxis_internals/classes/pnl2.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/pnl_chart_monthly.dart';

class PnLMonthlyPage extends StatefulWidget {
  const PnLMonthlyPage({super.key});

  @override
  State<PnLMonthlyPage> createState() => _PnLMonthlyState();
}

class _PnLMonthlyState extends State<PnLMonthlyPage> {
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

  List<PnL2>? clientData;
  List<PnL2>? hedgeData;

  var logger = Logger();

  Stream<List<PnL2>> pnlStream() async* {
    while (runStream) {
      String url = "${EnvConfig.restUrl}/v1/monthly-pnl/";
      try {
        final response = await NewClient.client!.get(Uri.parse(url));

        var responseData = json.decode(response.body);

        List<PnL2>? cPnls = [];
        List<PnL2>? hPnls = [];

        for (var pnl in responseData) {
          if (pnl["sum"] != null) {
            PnL2 newPnL = PnL2(
                eventTime: DateTime.parse(pnl["event_time"]).toLocal(),
                pnlChange: pnl["sum"]);
            if (pnl["hedge_or_client"] == "HEDGE") {
              hPnls.add(newPnL);
            } else {
              cPnls.add(newPnL);
            }
          }
        }
        lastUpdated = DateTime.now();
        cPnls.sort((a, b) => a.eventTime.compareTo(b.eventTime));
        clientData = cPnls;
        hPnls.sort((a, b) => a.eventTime.compareTo(b.eventTime));
        hedgeData = hPnls;
      } catch (e) {
        clientData = clientData ?? [];
        hedgeData = hedgeData ?? [];
        logger.e("Error retrieving Monthly PnL data from url: $url, retrying.");
      }

      yield clientData!;
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
            clientData != null
                ? Expanded(
                    child: clientData!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 20, 3),
                            child: PnLMonthlyChart(
                              clientData: clientData!,
                              hedgeData: hedgeData!,
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
