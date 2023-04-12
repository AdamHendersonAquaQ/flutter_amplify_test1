import 'dart:async';
import 'package:flutter_amplify_test/classes/position.dart';
import 'package:flutter_amplify_test/shared/filterbox.dart';
import 'package:flutter_amplify_test/shared/table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

import '../shared/subtitle.dart';

class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsState();
}

class _PositionsState extends State<PositionsPage> {
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
    {'label': "Symbol", 'value': "symbol", 'type': 'text'},
    {'label': "Position", 'value': "position", 'type': 'posNegative'},
  ];
  var filterValues = [
    {"label": "Symbol", "type": "text", "valType": "string", "value": ""},
    {
      "label": "Position",
      "type": "range",
      "valType": "int",
      "value": "",
      "value2": ""
    },
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
      for (var filter in filterValues) {
        if (filter['value']!.trim() != '' ||
            (filter['type'] == "range" && filter['value2']!.trim() != '')) {
          switch (filter['label']) {
            case "Symbol":
              positions = positions
                  .where((x) => x
                      .toMap()['symbol']
                      .toString()
                      .toLowerCase()
                      .contains(filter['value']!.trim().toLowerCase()))
                  .toList();
              break;
            case "Position range":
              if ((int.tryParse(filter['value']!) != null ||
                      filter['value']! == "") &&
                  (int.tryParse(filter['value2']!) != null ||
                      filter['value2']! == "")) {
                if (filter['value']! != "" && filter['value2']! != "") {
                  positions = positions
                      .where((x) =>
                          x.position <= int.parse(filter['value2']!) &&
                          x.position >= int.parse(filter['value']!))
                      .toList();
                } else if (filter['value'] != "") {
                  positions = positions
                      .where((x) => x.position >= int.parse(filter['value']!))
                      .toList();
                } else if (filter['value2']! != "") {
                  positions = positions
                      .where((x) => x.position <= int.parse(filter['value2']!))
                      .toList();
                }
              }
              break;
            default:
              break;
          }
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
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: StreamBuilder(
          stream: tradeStream(),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  Subtitle(
                    subtitle: "Positions",
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
          },
        ),
      ),
    );
  }
}
