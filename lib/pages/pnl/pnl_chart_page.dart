import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/pnl_chart_daily.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/pnl_chart_monthly.dart';
import 'package:praxis_internals/pages/pnl/shared.dart';
import 'package:praxis_internals/classes/pnl2.dart';

class PnLChartPage extends StatefulWidget {
  const PnLChartPage({super.key});

  @override
  State<StatefulWidget> createState() => PnLChartState();
}

class PnLChartState extends State<PnLChartPage> {
  List<PnL2>? clientData;
  List<PnL2>? hedgeData;

  bool showClient = true;
  void invertShowClient() {
    setState(() {
      showClient = !showClient;
    });
  }

  bool showHedge = true;
  void invertShowHedge() {
    setState(() {
      showHedge = !showHedge;
    });
  }

  DateTime date = DateTime.now();
  void setDateTime(DateTime dt) {
    setState(() {
      date = dt;
      clientData = null;
      hedgeData = null;
    });
  }

  int selectedCalender = 0;
  void setSelectedCalender(int cal) {
    setState(() {
      selectedCalender = cal;
      clientData = null;
      hedgeData = null;
    });
  }

  DateTime? lastUpdated;

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
          "${EnvConfig.restUrl}/v1/${selectedCalender == 0 ? "daily-pnl" : "monthly-pnl"}?date=${date.year}-${date.month}-${date.day}";
      try {
        final response = await NewClient.client!.get(Uri.parse(url));

        var responseData = json.decode(response.body);

        List<PnL2>? cPnls = [];
        List<PnL2>? hPnls = [];

        for (var pnl in responseData) {
          if (pnl[selectedCalender == 0 ? "pnl_change" : "sum"] != null) {
            PnL2 newPnL = PnL2(
                eventTime: DateTime.parse(pnl["event_time"]).toLocal(),
                pnlChange: pnl[selectedCalender == 0 ? "pnl_change" : "sum"]);
            if (pnl["hedge_or_client"] == "HEDGE") {
              hPnls.add(newPnL);
            } else {
              cPnls.add(newPnL);
            }
          }
        }
        lastUpdated = DateTime.now();

        clientData = cPnls;
        hedgeData = hPnls;
      } catch (e) {
        clientData = clientData ?? [];
        hedgeData = hedgeData ?? [];
        logger.e("Error retrieving PnL data from url: $url, retrying.");
      }

      yield clientData!;
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: PnLSegmentedButton(
                                  selectedCalender: selectedCalender,
                                  setSelectedCalender: setSelectedCalender,
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, left: 50),
                        child: Row(
                          children: [
                            const Text("Show Client Pnl: "),
                            Checkbox(
                                value: showClient,
                                onChanged: ((value) => invertShowClient())),
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("Show Hedge Pnl: "),
                            ),
                            Checkbox(
                              value: showHedge,
                              onChanged: ((value) => invertShowHedge()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    clientData != null
                        ? Expanded(
                            child: clientData!.isNotEmpty &&
                                    (showClient || showHedge)
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 30, 30, 15),
                                    child: selectedCalender == 0 &&
                                            clientData![0].eventTime.day ==
                                                clientData![1].eventTime.day
                                        ? PnLDailyChart(
                                            clientData:
                                                showClient ? clientData! : [],
                                            hedgeData:
                                                showHedge ? hedgeData! : [],
                                          )
                                        : PnLMonthlyChart(
                                            clientData:
                                                showClient ? clientData! : [],
                                            hedgeData:
                                                showHedge ? hedgeData! : [],
                                          ))
                                : Center(
                                    child: Text((!showClient && !showHedge)
                                        ? "You must select either Client or Hedge PnL data"
                                        : "No data available for this date")),
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
