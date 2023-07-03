import 'dart:async';
import 'package:praxis_internals/amplify/http_client.dart';
import 'package:praxis_internals/classes/sortmethods.dart';

import 'package:flutter/material.dart';
import 'package:praxis_internals/classes/trade.dart';
import 'package:logger/logger.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/filterbox.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/shared.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/subtitle.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/table.dart';
import 'package:praxis_internals/pages/pnl/shared.dart';
import 'package:praxis_internals/pages/trades/trades_shared.dart';

class TradesPage extends StatefulWidget {
  const TradesPage({super.key, this.openDrawer});
  final ValueChanged<Widget>? openDrawer;
  @override
  State<TradesPage> createState() => _TradesState();
}

class _TradesState extends State<TradesPage> {
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

  DateTime date = DateTime.now();
  void setDateTime(DateTime dt) {
    setState(() {
      date = dt;
      data = null;
    });
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
        final response = await NewClient.client!
            .get(Uri.parse("$url?date=${date.year}/${date.month}/${date.day}"));

        var trades = getTrades(response.body);
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Scaffold(
          body: StreamBuilder(
              stream: tradeStream(),
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                return Center(
                    child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          Subtitle(
                            subtitle:
                                "Trade Blotter (${date.day}/${date.month}/${date.year})",
                            lastUpdated: lastUpdated ?? DateTime.now(),
                            downloadCsv: data != null && data!.isNotEmpty
                                ? _exportCSV
                                : null,
                          ),
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
                                  paged: true,
                                  setData: _setData,
                                )
                        ],
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 10,
                        height: double.infinity,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      width: 415,
                      height: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                'Filter',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: noPadDivider,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 0, 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Showing PnL for: ${date.day}/${date.month}/${date.year}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  DatePickers(
                                    date: date,
                                    setDate: setDateTime,
                                  ),
                                ],
                              ),
                            ),
                            TradeSourceFilter(
                                sourceFilter: sourceFilter, setSF: _setSF),
                            FilterBox(
                              filterValues: headingList,
                              filterMethod: _filterData,
                              date: date,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ));
              })),
    );
  }
}
