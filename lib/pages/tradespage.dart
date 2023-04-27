import 'dart:async';
import 'package:flutter_amplify_test/classes/heading.dart';
import 'package:flutter_amplify_test/classes/sortmethods.dart';
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

  List<Heading> headingList = [
    Heading(
        label: "Time",
        name: "transactionTime",
        headingType: "text",
        valueType: "DateTime",
        value: "",
        value2: ""),
    Heading(
        label: "Symbol",
        name: "symbol",
        headingType: "text",
        valueType: "string",
        value: ""),
    Heading(
        label: "Last Price",
        name: "lastPrice",
        headingType: "posNegative",
        valueType: "double",
        value: "",
        value2: ""),
    Heading(
        label: "Quantity",
        name: "quantity",
        headingType: "text",
        valueType: "int",
        value: "",
        value2: ""),
    Heading(
        label: "Client Name",
        name: "clientName",
        headingType: "text",
        valueType: "string",
        value: ""),
  ];

  DateTime lastUpdated = DateTime.now();
  List<Trade>? data;
  var logger = Logger();

  Stream<List<Trade>> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      String url =
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=trades-dev";
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
        trades = SortMethods.filterList(trades, headingList).cast<Trade>();

        trades = SortMethods.sortList(
                trades, _isSortAsc, headingList, _currentSortColumn)
            .cast<Trade>();
        lastUpdated = DateTime.now();
        data = trades;
      } catch (e) {
        logger.e("Error retrieving Trades data from url: $url, retrying.");
      }

      yield data!;
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
                              filterValues: headingList),
                        NewTable(
                            currentSortColumn: _currentSortColumn,
                            isSortAsc: _isSortAsc,
                            headings: headingList,
                            data: snapshot.data,
                            setSortColumn: _setSortColumn,
                            setIsSortAsc: _setIsSortAsc)
                      ],
                    );
                  }
                })));
  }
}
