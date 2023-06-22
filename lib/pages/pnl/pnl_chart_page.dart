import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/pnl_chart_daily.dart';
import 'package:praxis_internals/pages/pnl/shared.dart';
import 'package:praxis_internals/classes/pnl2.dart';

class PnLChartPage extends StatefulWidget {
  const PnLChartPage({super.key, this.initCal});

  final int? initCal;
  @override
  State<StatefulWidget> createState() => PnLChartState();
}

class PnLChartState extends State<PnLChartPage> {
  List<PnL2>? data;

  DateTime date = DateTime.now();
  void setDateTime(DateTime dt) {
    setState(() {
      date = dt;
      data = null;
    });
  }

  DateTime? lastUpdated = DateTime.now();

  bool runStream = false;

  @override
  void dispose() {
    runStream = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    runStream = true;
  }

  var logger = Logger();

  Stream<List<PnL2>> pnlStream() async* {
    while (runStream) {
      String url =
          "${EnvConfig.restUrl}/pnl2?date=${date.year}-${date.month}-${date.day}";
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
        logger.e("Error retrieving Positions data from url: $url, retrying.");
      }

      yield data!;
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns:
          MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
              ? 3
              : 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Scaffold(
          body: StreamBuilder(
              stream: pnlStream(),
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 40),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Profit and Loss',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Showing PnL for: ${date.day}/${date.month}/${date.year}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: DatePickers(
                              date: date,
                              setDate: setDateTime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    data != null
                        ? Expanded(
                            child: data!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 30, 30, 15),
                                    child: PnLDailyChart(
                                      data: data!,
                                    ))
                                : const Center(
                                    child: Text(
                                        "No data available for this date")),
                          )
                        : const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
