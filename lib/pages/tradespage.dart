import 'dart:async';
import 'package:flutter_amplify_test/shared/colourVariables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/trade.dart';

import '../shared/filterbox.dart';
import '../shared/subtitle.dart';
import '../shared/table.dart';

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesState();
}

class _TradesState extends State<TradesPage> {
  int _currentSortColumn = 0;
  void _setSortColumn([int? currentSortColumn]) {
    setState(() {
      _currentSortColumn = currentSortColumn!;
    });
  }

  bool _isSortAsc = false;
  void _setIsSortAsc([bool? isSortAsc]) {
    setState(() {
      _isSortAsc = isSortAsc!;
    });
  }

  bool showFilter = false;
  void _flipShowFilter([int? temp]) {
    setState(() {
      showFilter = !showFilter;
    });
  }

  var headings = [
    {'label': "Time", 'value': "transactionTime", 'type': 'text'},
    {'label': "Symbol", 'value': "symbol", 'type': 'text'},
    {'label': "Last Price", 'value': "lastPrice", 'type': 'posNegative'},
    {'label': "Quantity", 'value': "quantity", 'type': 'text'},
    {'label': "Client Name", 'value': "clientName", 'type': 'text'},
  ];
  var filterValues = [
    {"label": "Min Time", "value": ""},
    {"label": "Max Time", "value": ""},
    {"label": "Symbol", "value": ""},
    {"label": "Max Last Price", "value": ""},
    {"label": "Min Last Price", "value": ""},
    {"label": "Max Quantity", "value": ""},
    {"label": "Min Quantity", "value": ""},
    {"label": "Client Name", "value": ""},
  ];
  Stream<List<Trade>> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      final response = await http.get(Uri.parse(
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades"));

      var responseData = json.decode(response.body);

      List<Trade> trades = [];
      for (var trade in responseData) {
        double price = trade["lastPrice"];
        if (trade["side"] == "BUY") {
          price = price * -1;
        }
        Trade newTrade = Trade(
          id: trade["id"],
          transactionTime: DateTime.parse(trade["transactTime"]),
          clientName: trade["clientName"],
          lastPrice: price,
          quantity: trade["quantity"],
          symbol: trade["symbol"],
        );

        trades.add(newTrade);
      }
      for (var filter in filterValues) {
        if (filter['value']!.trim() != '') {
          switch (filter['label']) {
            case "Max Time":
              trades = trades
                  .where((x) =>
                      x.transactionTime.isBefore(filter['value'] as DateTime))
                  .toList();
              break;
            case "Min Time":
              trades = trades
                  .where((x) =>
                      x.transactionTime.isAfter(filter['value'] as DateTime))
                  .toList();
              break;
            case "Symbol":
            case "Client Name":
              trades = trades
                  .where((x) => x
                      .toMap()['symbol']
                      .toString()
                      .toLowerCase()
                      .contains(filter['value']!.trim().toLowerCase()))
                  .toList();
              break;
            case "Max Last Price":
              trades = trades
                  .where((x) => x.lastPrice <= double.parse(filter['value']!))
                  .toList();
              break;
            case "Min Last Price":
              trades = trades
                  .where((x) => x.lastPrice >= double.parse(filter['value']!))
                  .toList();
              break;
            case "Max Quantity":
              trades = trades
                  .where((x) => x.quantity <= int.parse(filter['value']!))
                  .toList();
              break;
            case "Min Quantity":
              trades = trades
                  .where((x) => x.quantity >= int.parse(filter['value']!))
                  .toList();
              break;
            default:
              break;
          }
        }
      }
      if (_isSortAsc) {
        trades.sort((a, b) {
          var c = a.toMap();
          var d = b.toMap();
          return d[headings[_currentSortColumn]['value'].toString()].compareTo(
              c[headings[_currentSortColumn]['value'].toString()]) as int;
        });
      } else {
        trades.sort((a, b) {
          var c = a.toMap();
          var d = b.toMap();
          return c[headings[_currentSortColumn]['value'].toString()].compareTo(
              d[headings[_currentSortColumn]['value'].toString()]) as int;
        });
      }
      yield trades;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: secondaryBackground,
        ),
        home: Scaffold(
            body: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: StreamBuilder(
                    stream: tradeStream(),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            Subtitle(
                              subtitle: "Trade Blotter",
                              flipShowFilter: _flipShowFilter,
                            ),
                            if (showFilter)
                              FilterBox(
                                  flipShowFilter: _flipShowFilter,
                                  filterValues: filterValues),
                            NewTable(
                                currentSortColumn: _currentSortColumn,
                                isSortAsc: _isSortAsc,
                                headings: headings,
                                data: snapshot.data,
                                setSortColumn: _setSortColumn,
                                setIsSortAsc: _setIsSortAsc)
                          ],
                        );
                      }
                    }))));
  }
}
