import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/trade.dart';
import 'package:flutter_amplify_test/shared/centeredcell.dart';
import 'package:http/http.dart' as http;

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesState();
}

class _TradesState extends State<TradesPage> {
  Future<List<Trade>> getRequest() async {
    String url =
        "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades";
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    List<Trade> trades = [];
    for (var trade in responseData) {
      Trade newTrade = Trade(
        id: trade["id"],
        clientName: trade["clientName"],
        lastPrice: trade["lastPrice"],
        quantity: trade["quantity"],
        symbol: trade["symbol"],
      );

      trades.add(newTrade);
    }
    return trades;
  }

  @override
  Widget build(BuildContext context) {
    var headings = ["ID", "ClientName", "Symbol", "Last Price", "Quantity"];
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 83, 83, 83),
      ),
      home: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: FutureBuilder(
            future: getRequest(),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Container(
                  color: const Color.fromARGB(255, 83, 83, 83),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Table(
                    defaultColumnWidth: FixedColumnWidth(150),
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 27, 27, 27),
                          ),
                          children: [
                            for (var heading in headings)
                              Center(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Text(
                                  heading,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )),
                          ]),
                      for (var trade in snapshot.data)
                        TableRow(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 44, 44, 44),
                            ),
                            children: [
                              CenteredCell(cellText: trade.id.toString()),
                              CenteredCell(cellText: trade.clientName),
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Container(
                                    // color: trade.symbol == "[N/A]"
                                    //     ? Colors.red
                                    //     : Colors.blue,
                                    child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    trade.symbol,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                              ),
                              CenteredCell(
                                  cellText: trade.lastPrice.toString()),
                              CenteredCell(cellText: trade.quantity.toString()),
                            ]),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      )),
    );
  }
}
