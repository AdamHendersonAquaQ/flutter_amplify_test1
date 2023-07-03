import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/classes/pnl.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/dashboard_pnl/figures/pnl_widget.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/subtitle.dart';

class PnLDash extends StatefulWidget {
  const PnLDash({super.key});

  @override
  State<PnLDash> createState() => _PnLDashState();
}

class _PnLDashState extends State<PnLDash> {
  DateTime lastUpdated = DateTime.now();
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

  List<PnL>? data;
  var logger = Logger();

  Stream<List<PnL>> pnlStream() async* {
    while (runStream) {
      String url = "${EnvConfig.restUrl}/v1/pnl";

      try {
        final response = await NewClient.client!.get(Uri.parse(url));
        var vals = json.decode(response.body);

        List<PnL> pnls = [];
        for (var val in vals) {
          String source = val["hedge_or_client"];
          if (data != null) {
            pnls.add(PnL(
                source: source,
                sum: val["sum"],
                previousSum: data![source == "CLIENT" ? 0 : 1].sum));
          } else {
            pnls.add(PnL(source: source, sum: val["sum"]));
          }
        }

        data = pnls;
        lastUpdated = DateTime.now();
      } catch (e) {
        data = data ?? [];
        logger.e("Error retrieving PnL data from url: $url, retrying.");
      }
      yield data!;
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: pnlStream(),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          return data == null || data!.isEmpty
              ? Center(
                  child: data == null
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("No pnl data is currently avaiable"),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PnLWidget(data: data![0], label: "Client"),
                    PnLWidget(data: data![1], label: "Hedge"),
                    SizedBox(
                        width: 130,
                        child: LastUpdatedLabel(lastUpdated: lastUpdated))
                  ],
                );
        });
  }
}
