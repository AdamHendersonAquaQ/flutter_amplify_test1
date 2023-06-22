import 'dart:async';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/classes/sortmethods.dart';

import 'package:flutter/material.dart';
import 'package:praxis_internals/classes/trade.dart';
import 'package:logger/logger.dart';
import 'package:praxis_internals/pages/trades/trades_shared.dart';

import 'shared/filterbox.dart';
import 'shared/subtitle.dart';
import 'shared/table.dart';

class TradesDash extends StatefulWidget {
  const TradesDash({super.key, this.openDrawer});
  final ValueChanged<Widget>? openDrawer;
  @override
  State<TradesDash> createState() => _TradesState();
}

class _TradesState extends State<TradesDash> {
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

  DateTime? lastUpdated;
  List<Trade>? data;
  void _setData() {
    data =
        SortMethods.sortList(data!, _isSortAsc, headingList, _currentSortColumn)
            .cast<Trade>();
  }

  var logger = Logger();

  void _filterData() {
    setState(() {
      data = SortMethods.filterList(data!, headingList).cast<Trade>();
    });
  }

  String sourceFilter = "";
  void _setSF(String sf) {
    setState(() {
      sourceFilter = sf;
    });
  }

  Future<void> _exportCSV() async {
    exportCSV(data!);
  }

  Stream<List<Trade>> tradeStream() async* {
    while (runStream) {
      try {
        final response = await NewClient.client!.get(Uri.parse(url));

        List<Trade> trades = getTrades(response.body);

        trades = SortMethods.filterList(trades, headingList).cast<Trade>();
        trades = SortMethods.filterSource(trades, sourceFilter).cast<Trade>();
        trades = SortMethods.sortList(
                trades, _isSortAsc, headingList, _currentSortColumn)
            .cast<Trade>();
        lastUpdated = DateTime.now();
        data = trades;
      } catch (e) {
        data = data ?? [];
        logger.e("Error retrieving Trades data from url: $url, retrying.");
      }

      yield data!;
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
            child: StreamBuilder(
                stream: tradeStream(),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  return Column(
                    children: [
                      Subtitle(
                          subtitle:
                              "Trade Blotter (${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day})",
                          tooltip: tradesTooltip,
                          lastUpdated: lastUpdated ?? DateTime.now(),
                          destination: "/trades",
                          downloadCsv: data != null && data!.isNotEmpty
                              ? _exportCSV
                              : null,
                          openDrawer: () => widget.openDrawer!(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TradeSourceFilter(
                                      sourceFilter: sourceFilter,
                                      setSF: _setSF),
                                  FilterBox(
                                    filterValues: headingList,
                                    filterMethod: _filterData,
                                    date: DateTime.now(),
                                  ),
                                ],
                              ))),
                      data == null || data!.isEmpty
                          ? Expanded(
                              child: Center(
                                child: data == null
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        "No trades data is currently avaiable"),
                              ),
                            )
                          : NewTable(
                              currentSortColumn: _currentSortColumn,
                              isSortAsc: _isSortAsc,
                              headings: headingList,
                              data: snapshot.data,
                              setSortColumn: _setSortColumn,
                              setIsSortAsc: _setIsSortAsc,
                              isDashboard: true,
                              paged: true,
                              setData: _setData,
                            )
                    ],
                  );
                })));
  }
}
