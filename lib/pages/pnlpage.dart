import 'dart:async';
import 'package:flutter_amplify_test/classes/pnl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class PnLPage extends StatefulWidget {
  const PnLPage({super.key});

  @override
  State<PnLPage> createState() => _PnLState();
}

class _PnLState extends State<PnLPage> {
  Stream<PnL> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      // final response = await http.get(Uri.parse(
      //     "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades"));

      yield PnL(totalPnL: 367232400, dailyPnL: 2059428, change: 1);
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
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Row(children: [
                const Expanded(
                  child: Text(
                    "Profit and Loss (PnL)",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
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
                        Text(
                          '\$${cy.format(snapshot.data.totalPnL)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Icon(
                            snapshot.data.change > 0
                                ? Icons.keyboard_arrow_up_outlined
                                : Icons.keyboard_arrow_down_outlined,
                            color: snapshot.data.change > 0 ? pnlGreen : pnlRed,
                          ),
                        ),
                        Text(
                          '\$${cy.format(snapshot.data.dailyPnL)} (${snapshot.data.change}%)',
                          style: TextStyle(
                            color: snapshot.data.change > 0 ? pnlGreen : pnlRed,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]);
            }
          },
        ),
      ),
    );
  }
}
