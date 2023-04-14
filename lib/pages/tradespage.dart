import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/trade.dart';
import 'package:logger/logger.dart';

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
    {
      "label": "Time",
      "type": "range",
      "valType": "DateTime",
      "value": "",
      "value2": ""
    },
    {"label": "Symbol", "type": "text", "valType": "string", "value": ""},
    {
      "label": "Last Price",
      "type": "range",
      "valType": "double",
      "value": "",
      "value2": ""
    },
    {
      "label": "Quantity",
      "type": "range",
      "valType": "int",
      "value": "",
      "value2": ""
    },
    {"label": "Client Name", "type": "text", "valType": "string", "value": ""},
  ];
  DateTime lastUpdated = DateTime.now();
  List<Trade>? data;
  var logger = Logger();

  Stream<List<Trade>> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      String url =
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades";
      try {
        final response = await http.get(Uri.parse(url));

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
        trades = filterTrades(trades);
        sortTrades(trades);
        lastUpdated = DateTime.now();
        data = trades;
      } catch (e) {
        logger.e("Error retrieving Trades data from url: $url, retrying.");
      }

      yield data!;
    }
  }

  List<Trade> filterTrades(List<Trade> trades) {
    for (var filter in filterValues) {
      if (filter['value']!.trim() != '' ||
          (filter['type'] == "range" && filter['value2']!.trim() != '')) {
        switch (filter['label']) {
          case "Time":
            bool val1IsDT = DateTime.tryParse(filter['value']!) != null;
            bool val2IsDT = DateTime.tryParse(filter['value2']!) != null;
            if ((val1IsDT || filter['value']! == "") &&
                (val2IsDT || filter['value2']! == "")) {
              if (val1IsDT && val2IsDT) {
                trades = trades
                    .where((x) =>
                        x.transactionTime
                            .isBefore(DateTime.parse(filter['value2']!)) &&
                        x.transactionTime
                            .isAfter(DateTime.parse(filter['value']!)))
                    .toList();
              } else if (val1IsDT && filter['value2']! == "") {
                trades = trades
                    .where((x) => x.transactionTime
                        .isAfter(DateTime.parse(filter['value']!)))
                    .toList();
              } else if (val2IsDT && filter['value']! == "") {
                trades = trades
                    .where((x) => x.transactionTime
                        .isBefore(DateTime.parse(filter['value2']!)))
                    .toList();
              }
            }
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
          case "Last Price":
            if ((double.tryParse(filter['value']!) != null ||
                    filter['value']! == "") &&
                (double.tryParse(filter['value2']!) != null ||
                    filter['value2']! == "")) {
              if (filter['value']! != "" && filter['value2']! != "") {
                trades = trades
                    .where((x) =>
                        x.lastPrice <= double.parse(filter['value2']!) &&
                        x.lastPrice >= double.parse(filter['value']!))
                    .toList();
              } else if (filter['value'] != "") {
                trades = trades
                    .where((x) => x.lastPrice >= double.parse(filter['value']!))
                    .toList();
              } else if (filter['value2']! != "") {
                trades = trades
                    .where(
                        (x) => x.lastPrice <= double.parse(filter['value2']!))
                    .toList();
              }
            }
            break;
          case "Quantity":
            if ((int.tryParse(filter['value']!) != null ||
                    filter['value']! == "") &&
                (int.tryParse(filter['value2']!) != null ||
                    filter['value2']! == "")) {
              if (filter['value']! != "" && filter['value2']! != "") {
                trades = trades
                    .where((x) =>
                        x.quantity <= int.parse(filter['value2']!) &&
                        x.quantity >= int.parse(filter['value']!))
                    .toList();
              } else if (filter['value'] != "") {
                trades = trades
                    .where((x) => x.quantity >= int.parse(filter['value']!))
                    .toList();
              } else if (filter['value2']! != "") {
                trades = trades
                    .where((x) => x.quantity <= int.parse(filter['value2']!))
                    .toList();
              }
            }
            break;
          default:
            break;
        }
      }
    }
    return trades;
  }

  void sortTrades(List<Trade> trades) {
    if (_isSortAsc) {
      trades.sort((a, b) {
        var c = a.toMap();
        var d = b.toMap();
        return d[headings[_currentSortColumn]['value'].toString()]
                .compareTo(c[headings[_currentSortColumn]['value'].toString()])
            as int;
      });
    } else {
      trades.sort((a, b) {
        var c = a.toMap();
        var d = b.toMap();
        return c[headings[_currentSortColumn]['value'].toString()]
                .compareTo(d[headings[_currentSortColumn]['value'].toString()])
            as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                        Subtitle(
                          subtitle: "Trade Blotter",
                          lastUpdated: lastUpdated,
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
                })));
  }
}
