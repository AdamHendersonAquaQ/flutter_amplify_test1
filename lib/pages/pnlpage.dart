import 'dart:async';
import 'package:flutter_amplify_test/classes/pnl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PnLPage extends StatefulWidget {
  const PnLPage({super.key});

  @override
  State<PnLPage> createState() => _PnLState();
}

class _PnLState extends State<PnLPage> {
  DateTime lastUpdated = DateTime.now();
  PnL? data;
  var logger = Logger();

  Stream<PnL> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      String url =
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades";

      try {
        final response = await http.get(Uri.parse(url));
        data = PnL(totalPnL: 367232400, dailyPnL: 2059428, change: 1);
        lastUpdated = DateTime.now();
      } catch (e) {
        logger.e("Error retrieving PnL data from url: $url, retrying.");
      }
      yield data!;
    }
  }

  final cy = NumberFormat("#,##0", "en_US");

  final pnlGreen = const Color.fromARGB(255, 0, 255, 8);
  final pnlRed = const Color.fromARGB(255, 255, 17, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 40, 0),
        child: StreamBuilder(
          stream: tradeStream(),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(children: [
                          const Expanded(
                            child: Text(
                              "Profit and Loss (PnL)",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  SelectableText(
                                    '\$${cy.format(data!.totalPnL)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Icon(
                                      data!.change > 0
                                          ? Icons.keyboard_arrow_up_outlined
                                          : Icons.keyboard_arrow_down_outlined,
                                      color:
                                          data!.change > 0 ? pnlGreen : pnlRed,
                                    ),
                                  ),
                                  SelectableText(
                                    '\$${cy.format(data!.dailyPnL)} (${data!.change}%)',
                                    style: TextStyle(
                                      color:
                                          data!.change > 0 ? pnlGreen : pnlRed,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Last Update: ${DateFormat('yyyy/MM/dd kk:mm:ss').format(lastUpdated)}",
                        style: TextStyle(
                          color: DateTime.now()
                                      .difference(lastUpdated)
                                      .inSeconds >=
                                  10
                              ? Colors.white
                              : const Color.fromARGB(0, 0, 0, 0),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
