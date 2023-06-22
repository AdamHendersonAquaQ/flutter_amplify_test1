import 'dart:async';
import 'dart:convert';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/classes/pnl.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/subtitle.dart';

class PnLWidget extends StatefulWidget {
  const PnLWidget({super.key, required this.endpoint, required this.label});

  final String label;
  final String endpoint;

  @override
  State<PnLWidget> createState() => _PnLWidgetState();
}

class _PnLWidgetState extends State<PnLWidget> {
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
  PnL? data;
  var logger = Logger();

  Stream<PnL> tradeStream() async* {
    while (runStream) {
      String url = "${EnvConfig.restUrl}/${widget.endpoint}";

      try {
        final response = await NewClient.client!.get(Uri.parse(url));
        var pnl = json.decode(response.body)[0];
        int change = 0;
        double? previousPnL;
        if (data != null && pnl["pnl_change"] != null) {
          if (data!.totalPnL! > pnl["pnl_change"]) {
            previousPnL = data!.totalPnL;
            change = -1;
          } else if (data!.totalPnL! < pnl["pnl_change"]) {
            previousPnL = data!.totalPnL;
            change = 1;
          } else {
            if (data?.previousPnL != null) {
              previousPnL = data?.previousPnL;
            }
            change = data!.change;
          }

          data = previousPnL == null
              ? PnL(totalPnL: pnl["pnl_change"], change: change)
              : PnL(
                  totalPnL: pnl["pnl_change"],
                  previousPnL: previousPnL,
                  change: change);
        } else {
          data = PnL(totalPnL: pnl["pnl_change"], change: change);
        }
        lastUpdated = DateTime.now();
      } catch (e) {
        logger.e("Error retrieving PnL data from url: $url, retrying.");
      }
      yield data!;
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  final cy = NumberFormat("#,##0.000", "en_US");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: tradeStream(),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (data == null) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        } else {
          return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: Text(
                    "${widget.label} PnL:",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                data!.totalPnL != null
                    ? Icon(
                        size: 18,
                        data!.totalPnL! > 0
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_outlined,
                        color: data!.totalPnL == 0
                            ? Theme.of(context).scaffoldBackgroundColor
                            : data!.totalPnL! > 0
                                ? Colors.green
                                : Colors.red,
                      )
                    : Icon(Icons.keyboard_arrow_up_outlined,
                        color: Theme.of(context).scaffoldBackgroundColor),
                Tooltip(
                  message: data!.change == 0
                      ? "No Previous value available"
                      : "Previous: \$${cy.format(data!.previousPnL)}",
                  child: SelectableText(
                    data!.totalPnL != null
                        ? '\$${cy.format(data!.totalPnL)}'
                        : "PnL is currently unavailable",
                    style: TextStyle(
                      color: data!.totalPnL != null
                          ? (data!.totalPnL == 0
                              ? Colors.white
                              : data!.totalPnL! > 0
                                  ? Colors.green
                                  : Colors.red)
                          : null,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    width: 130,
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: LastUpdatedLabel(
                          lastUpdated: lastUpdated,
                        )),
                  ),
                )
              ]);
        }
      },
    );
  }
}
