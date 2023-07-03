import 'dart:async';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/classes/file_download.dart';
import 'package:praxis_internals/classes/heading.dart';
import 'package:praxis_internals/classes/trade.dart';

String url = "${EnvConfig.restUrl}/v1/trades";

Future<void> exportCSV(List data) async {
  List<List<dynamic>> rows = [];
  rows.add([
    "id",
    "transaction time",
    "symbol",
    "last price",
    "quanity",
    "client name",
    "source"
  ]);

  for (var pos in data) {
    var map = pos.toMap();
    rows.add([
      map["id"],
      map["transactionTime"],
      map["symbol"],
      map["lastPrice"],
      map["quantity"],
      map["clientName"],
      map["source"]
    ]);
  }

  String csv = const ListToCsvConverter().convert(rows);
  FileDownload.downloadCsv("trades", csv);
}

List<Heading> headingList = [
  Heading(
      label: "Time",
      name: "transactionTime",
      headingType: "text",
      valueType: "DateTime",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
  Heading(
      label: "Symbol",
      name: "symbol",
      headingType: "text",
      valueType: "string",
      value: "",
      comparator: Comparator.isEqual),
  Heading(
      label: "Last Price",
      name: "lastPrice",
      headingType: "text",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isEqual),
  Heading(
      label: "Quantity",
      name: "quantity",
      headingType: "posNegative",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
  Heading(
      label: "Client Name",
      name: "clientName",
      headingType: "text",
      valueType: "string",
      value: "",
      comparator: Comparator.isEqual),
];

List<Trade> getTrades(var body) {
  var responseData = json.decode(body);
  List<Trade> trades = [];
  for (var trade in responseData) {
    double quant = trade["quantity"];
    String source = trade["source_system"] ?? "Onezero";

    if ((trade["side"] == "BUY" && source != "CMG") ||
        (trade["side"] == "SELL" && source == "CMG")) {
      quant = quant * -1;
    }
    Trade newTrade = Trade(
        id: trade["id"],
        transactionTime: DateTime.parse(trade["transact_time"]).toLocal(),
        clientName: trade["client_name"],
        lastPrice: trade["last_price"],
        quantity: quant,
        symbol: trade["praxis_symbol"] ?? trade["symbol"],
        source: source);

    trades.add(newTrade);
  }
  return trades;
}

class TradeSourceFilter extends StatefulWidget {
  const TradeSourceFilter(
      {super.key, required this.sourceFilter, required this.setSF});

  final String sourceFilter;
  final ValueChanged<String> setSF;

  @override
  State<TradeSourceFilter> createState() => _TradeSourceFilterState();
}

class _TradeSourceFilterState extends State<TradeSourceFilter> {
  String temp = "";
  @override
  void initState() {
    super.initState();
    temp = widget.sourceFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 0, 3),
            child: Text(
              "System Source:",
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: 170,
            child: DropdownButton<String>(
                isExpanded: true,
                isDense: true,
                value: temp,
                elevation: 16,
                style: const TextStyle(color: Colors.blue, fontSize: 16),
                onChanged: (String? value) {
                  widget.setSF(value ?? "");
                  setState(() {
                    temp = value ?? "";
                  });
                },
                items: const [
                  DropdownMenuItem<String>(
                    value: "",
                    child: Text("All"),
                  ),
                  DropdownMenuItem<String>(
                    value: "Client",
                    child: Text("Client"),
                  ),
                  DropdownMenuItem<String>(
                    value: "Hedge",
                    child: Text("Hedge"),
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
