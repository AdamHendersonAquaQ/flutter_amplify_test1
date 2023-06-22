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

String url = "${EnvConfig.restUrl}/prices";
List<Position> getPositions(var body) {
  var responseData = json.decode(body);

  List<Position>? positions = [];
  for (var pos in responseData) {
    Position newPosition = Position(
        position: pos["sum"],
        symbol: pos["praxis_symbol"],
        hedge: pos["hedge"] ?? 0,
        nett: pos["nett"] ?? 0,
        latestPrice: pos["latest_price"] ?? 0,
        value: pos["value"] ?? 0);

    positions.add(newPosition);
  }

  return positions;
}

Future<void> exportCSV(data) async {
  List<List<dynamic>> rows = [];
  rows.add(["symbol", "position", "latestPrice"]);

  for (var pos in data!) {
    var map = pos.toMap();
    rows.add([map["symbol"], map["position"], map["latestPrice"]]);
  }

  String csv = const ListToCsvConverter().convert(rows);
  FileDownload.downloadCsv("positions", csv);
}
