import 'dart:async';
import 'package:flutter_amplify_test/classes/heading.dart';
import 'package:flutter_amplify_test/classes/position.dart';
import 'package:flutter_amplify_test/shared/filterbox.dart';
import 'package:flutter_amplify_test/classes/sortmethods.dart';
import 'package:flutter_amplify_test/shared/table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

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

  List<Heading> headingList = [
    Heading(
        label: "Symbol",
        name: "symbol",
        headingType: "text",
        valueType: "string",
        value: ""),
    Heading(
        label: "Position",
        name: "position",
        headingType: "posNegative",
        valueType: "int",
        value: "",
        value2: ""),
  ];

  DateTime lastUpdated = DateTime.now();
  List<Position>? data;
  var logger = Logger();

  Stream<List<Position>> tradeStream() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      String url =
          "https://11nfsd5x34.execute-api.us-east-2.amazonaws.com/default/messages?TableName=Positions";
      try {
        final response = await http.get(Uri.parse(url));

        var responseData = json.decode(response.body);

        List<Position>? positions = [];
        for (var pos in responseData) {
          Position newPosition = Position(
            position: pos["Position"],
            symbol: pos["Symbol"],
          );

          positions.add(newPosition);
        }
        positions =
            SortMethods.filterList(positions, headingList).cast<Position>();
        positions = SortMethods.sortList(
                positions, _isSortAsc, headingList, _currentSortColumn)
            .cast<Position>();
        lastUpdated = DateTime.now();
        data = positions;
      } catch (e) {
        logger.e("Error retrieving Positions data from url: $url, retrying.");
      }

      yield data!;
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
            if (data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  Subtitle(
                    subtitle: "Positions",
                    flipShowFilter: _flipShowFilter,
                    lastUpdated: lastUpdated,
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
          },
        ),
      ),
    );
  }
}
