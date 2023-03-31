import 'dart:async';
import 'package:flutter_amplify_test/classes/position.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/trade.dart';

class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsState();
}

class _PositionsState extends State<PositionsPage> {
  int _currentSortColumn = 0;
  bool _isSortAsc = false;
  var headings = [
    {'label': "Symbol", 'value': "symbol", 'filterVal': ''},
    {'label': "Position", 'value': "position", 'filterVal': ''},
  ];
  Stream<List<Position>> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      final response = await http.get(Uri.parse(
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Positions"));

      var responseData = json.decode(response.body);

      List<Position> positions = [];
      for (var pos in responseData) {
        Position newPosition = Position(
          position: pos["Position"],
          symbol: pos["Symbol"],
        );

        positions.add(newPosition);
      }
      for (var heading in headings) {
        if (heading['filterVal']!.trim() != '') {
          positions = positions
              .where((x) => x
                  .toMap()[heading['value']]
                  .toString()
                  .toLowerCase()
                  .contains(heading['filterVal']!.toLowerCase()))
              .toList();
        }
      }

      if (_isSortAsc) {
        positions.sort((a, b) {
          var c = a.toMap();
          var d = b.toMap();
          return d[headings[_currentSortColumn]['value'].toString()].compareTo(
              c[headings[_currentSortColumn]['value'].toString()]) as int;
        });
      } else {
        positions.sort((a, b) {
          var c = a.toMap();
          var d = b.toMap();
          return c[headings[_currentSortColumn]['value'].toString()].compareTo(
              d[headings[_currentSortColumn]['value'].toString()]) as int;
        });
      }

      yield positions;
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
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 15),
                      child: Row(
                        children: const [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Positions",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        color: const Color.fromARGB(255, 75, 75, 75),
                        child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              dividerThickness: 1,
                              dataRowHeight: 35,
                              headingRowHeight: 35,
                              showBottomBorder: true,
                              border: TableBorder.all(
                                width: 1,
                                color: Colors.black,
                              ),
                              headingRowColor:
                                  MaterialStateProperty.resolveWith(
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
                                          padding:
                                              const EdgeInsets.only(left: 35),
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
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(
                                                    _isSortAsc
                                                        ? Icons.arrow_upward
                                                        : Icons.arrow_downward,
                                                    color: Colors.blue,
                                                    size: 20),
                                              )
                                            else
                                              const Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(
                                                    Icons.arrow_downward,
                                                    color: Colors.black,
                                                    size: 20),
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
                                for (var pos in snapshot.data)
                                  DataRow(
                                      color: MaterialStateProperty.resolveWith<
                                          Color>((Set<MaterialState> states) {
                                        if (snapshot.data.indexOf(pos) % 2 ==
                                            0) {
                                          return const Color.fromARGB(
                                                  255, 130, 174, 189)
                                              .withOpacity(0.3);
                                        }
                                        return const Color.fromARGB(
                                            255, 116, 116, 116);
                                      }),
                                      cells: [
                                        for (var heading in headings)
                                          DataCell(
                                            Center(
                                              child: Text(
                                                pos
                                                    .toMap()[heading['value']]
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ]),
                              ],
                            ))),
                  ],
                );
              }
            },
          ),
        ),
      )),
    );
  }
}
