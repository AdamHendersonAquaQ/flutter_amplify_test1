import 'dart:async';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/classes/file_download.dart';
import 'package:praxis_internals/classes/heading.dart';
import 'package:praxis_internals/classes/position.dart';
import 'package:csv/csv.dart';

import 'dart:convert';

List<Heading> headingList = [
  Heading(
      label: "Symbol",
      name: "symbol",
      headingType: "text",
      valueType: "string",
      value: "",
      comparator: Comparator.isEqual),
  Heading(
      label: "Latest Price",
      name: "latestPrice",
      headingType: "text",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
  Heading(
      label: "Client",
      name: "position",
      headingType: "posNegative",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
  Heading(
      label: "Hedge",
      name: "hedge",
      headingType: "posNegative",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
  Heading(
      label: "Nett",
      name: "nett",
      headingType: "posNegative",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
  Heading(
      label: "Value",
      name: "value",
      headingType: "text",
      valueType: "double",
      value: "",
      value2: "",
      comparator: Comparator.isBetween),
];

String url = "${EnvConfig.restUrl}/v1/positions";

List<Position> getPositions(var body) {
  var responseData = json.decode(body);

  List<Position>? positions = [];
  for (var pos in responseData) {
    double hedgePos = pos["hedge_position"] ?? 0;
    double clientPos = pos["client_position"] ?? pos["sum"] ?? 0;
    Position newPosition = Position(
        position: clientPos,
        symbol: pos["symbol"] ?? pos["praxis_symbol"] ?? "",
        hedge: hedgePos,
        nett: clientPos - hedgePos,
        latestPrice: pos["latest_price"] ?? 0,
        value: ((pos["client_value"] ?? 0) - (pos["hedge_value"] ?? 0)).abs());

    positions.add(newPosition);
  }

  return positions;
}

Future<void> exportCSV(data) async {
  List<List<dynamic>> rows = [];
  rows.add(["symbol", "latestPrice", "position", "hedge", "nett", "value"]);

  for (var pos in data!) {
    var map = pos.toMap();
    rows.add([
      map["symbol"],
      map["latestPrice"],
      map["position"],
      map["hedge"],
      map["nett"],
      map["value"]
    ]);
  }

  String csv = const ListToCsvConverter().convert(rows);
  FileDownload.downloadCsv("positions", csv);
}
