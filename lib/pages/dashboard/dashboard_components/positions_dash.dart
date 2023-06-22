import 'dart:async';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/classes/position.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/filterbox.dart';
import 'package:praxis_internals/classes/sortmethods.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/table.dart';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';
import 'package:praxis_internals/pages/positions/positions_shared.dart';

import 'shared/subtitle.dart';

class PositionsDash extends StatefulWidget {
  const PositionsDash({super.key, this.openDrawer});
  final ValueChanged<Widget>? openDrawer;
  @override
  State<PositionsDash> createState() => _PositionsState();
}

class _PositionsState extends State<PositionsDash> {
  bool runStream = false;
  @override
  void initState() {
    runStream = true;
    super.initState();
  }

  @override
  void dispose() {
    runStream = false;
    super.dispose();
  }

  int _currentSortColumn = 2;
  void _setSortColumn([int? currentSortColumn]) {
    setState(() {
      _currentSortColumn = currentSortColumn!;
    });
  }

  bool _isSortAsc = true;
  void _setIsSortAsc([bool? isSortAsc]) {
    setState(() {
      _isSortAsc = isSortAsc!;
    });
  }

  DateTime? lastUpdated;
  List<Position>? data;
  void _setData() {
    SortMethods.sortList(data!, _isSortAsc, headingList, _currentSortColumn)
        .cast<Position>();
  }

  void _filterData() {
    setState(() {
      data = SortMethods.filterList(data!, headingList).cast<Position>();
    });
  }

  var logger = Logger();

  Stream<List<Position>> tradeStream() async* {
    while (runStream) {
      try {
        final response = await NewClient.client!.get(Uri.parse(url));

        List<Position>? positions = getPositions(response.body);
        positions =
            SortMethods.filterList(positions, headingList).cast<Position>();
        positions = SortMethods.sortList(
                positions, _isSortAsc, headingList, _currentSortColumn)
            .cast<Position>();
        lastUpdated = DateTime.now();
        data = positions;
      } catch (e) {
        data = data ?? [];
        logger.e("Error retrieving Positions data from url: $url, retrying.");
      }

      yield data!;
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  Future<void> _exportCSV() async {
    exportCSV(data!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(12, 5, 12, 15),
        child: StreamBuilder(
            stream: tradeStream(),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              return Column(
                children: [
                  Subtitle(
                      subtitle: "Positions",
                      lastUpdated: lastUpdated ?? DateTime.now(),
                      destination: "/positions",
                      downloadCsv:
                          data != null && data!.isNotEmpty ? _exportCSV : null,
                      openDrawer: () => widget.openDrawer!(FilterBox(
                          filterValues: headingList,
                          filterMethod: _filterData))),
                  data == null || data!.isEmpty
                      ? Expanded(
                          child: Center(
                            child: data == null
                                ? const CircularProgressIndicator()
                                : const Text(
                                    "No positions data is currently avaiable"),
                          ),
                        )
                      : NewTable(
                          currentSortColumn: _currentSortColumn,
                          isSortAsc: _isSortAsc,
                          headings: headingList,
                          data: snapshot.data,
                          setSortColumn: _setSortColumn,
                          setIsSortAsc: _setIsSortAsc,
                          paged: false,
                          setData: _setData,
                          isDashboard: true,
                        ),
                ],
              );
            }),
      ),
    );
  }
}
