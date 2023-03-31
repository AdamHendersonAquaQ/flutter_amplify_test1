import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/trade.dart';

class TradesPage extends StatefulWidget {
  const TradesPage({super.key});

  @override
  State<TradesPage> createState() => _TradesState();
}

class _TradesState extends State<TradesPage> {
  int _currentSortColumn = 0;
  bool _isSortAsc = false;
  var headings = [
    {'label': "ID", 'value': "id", 'filterVal': ''},
    {'label': "Client Name", 'value': "clientName", 'filterVal': ''},
    {'label': "Symbol", 'value': "symbol", 'filterVal': ''},
    {'label': "Last Price", 'value': "lastPrice", 'filterVal': ''},
    {'label': "Quantity", 'value': "quantity", 'filterVal': ''},
  ];
  Stream<List<Trade>> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      final response = await http.get(Uri.parse(
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Trades"));

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
      for (var heading in headings) {
        if (heading['filterVal']!.trim() != '') {
          trades = trades
              .where((x) => x
                  .toMap()[heading['value']]
                  .toString()
                  .toLowerCase()
                  .contains(heading['filterVal']!.toLowerCase()))
              .toList();
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
        scaffoldBackgroundColor: Color.fromARGB(255, 83, 83, 83),
      ),
      home: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                return Container(
                    color: Color.fromARGB(255, 75, 75, 75),
                    child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          dividerThickness: 1,
                          dataRowHeight: 35,
                          showBottomBorder: true,
                          border: TableBorder.all(
                            width: 1,
                            color: Colors.black,
                          ),
                          headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.black),
                          sortColumnIndex: _currentSortColumn,
                          sortAscending: _isSortAsc,
                          columns: [
                            for (var heading in headings)
                              DataColumn(
                                label: Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Row(children: [
                                            Expanded(
                                              child: Text(
                                                heading['label'].toString(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            if (_currentSortColumn ==
                                                headings.indexOf(heading))
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Icon(
                                                    _isSortAsc
                                                        ? Icons.arrow_upward
                                                        : Icons.arrow_downward,
                                                    color: Colors.blue,
                                                    size: 15),
                                              )
                                            else
                                              const Align(
                                                alignment: Alignment.topRight,
                                                child: Icon(
                                                    Icons.arrow_downward,
                                                    color: Colors.black,
                                                    size: 15),
                                              )
                                          ]),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 200,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 243, 243, 243),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Color.fromARGB(
                                                          255, 102, 102, 102),
                                                      spreadRadius: 2),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: TextField(
                                                  onChanged: (text) {
                                                    heading['filterVal'] = text;
                                                  },
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.blue,
                                                  ),
                                                  decoration: InputDecoration(
                                                      focusedBorder: null),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                ),
                                onSort: (columnIndex, _) {
                                  setState(() {
                                    if (_currentSortColumn == columnIndex) {
                                      _isSortAsc = !_isSortAsc;
                                    } else {
                                      _currentSortColumn = columnIndex;
                                      _isSortAsc = false;
                                    }
                                  });
                                },
                              ),
                          ],
                          rows: [
                            for (var trade in snapshot.data)
                              DataRow(cells: [
                                DataCell(
                                  Center(
                                    child: Text(
                                      trade.id.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      trade.clientName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      trade.symbol,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      trade.lastPrice.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      trade.quantity.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          ],
                        )));
              }
            },
          ),
        ),
      )),
    );
  }
}
