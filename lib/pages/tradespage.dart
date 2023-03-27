import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/trade.dart';
import 'package:http/http.dart' as http;

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesState();
}

class _TradesState extends State<TradesPage> {
  Future<List<Trade>> getRequest() async {
    //replace your restFull API here.
    String url =
        "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades";
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    //Creating a list to store input data;
    List<Trade> trades = [];
    for (var trade in responseData) {
      Trade newTrade = Trade(
        id: trade["id"],
        clientName: trade["clientName"],
        lastPrice: trade["lastPrice"],
        quantity: trade["quantity"],
        symbol: trade["symbol"],
      );

      //Adding user to the list.
      trades.add(newTrade);
    }
    return trades;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Table(
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      const TableRow(children: [
                        Text('ID'),
                        Text('Client Name'),
                        Text('Symbol'),
                        Text('Last Price'),
                        Text('Quantity'),
                      ]),
                      for (var trade in snapshot.data)
                        TableRow(children: [
                          Text(trade.id.toString()),
                          Text(trade.clientName),
                          Text(trade.symbol),
                          Text(trade.lastPrice.toString()),
                          Text(trade.quantity.toString()),
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
