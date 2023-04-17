import 'package:flutter_amplify_test/classes/heading.dart';

class SortMethods {
  static List sortList(List list, bool isSortAsc, List<Heading> headings,
      int currentSortColumn) {
    list.sort((a, b) {
      return b
          .toMap()[headings[currentSortColumn].name]
          .compareTo(a.toMap()[headings[currentSortColumn].name]) as int;
    });
    if (!isSortAsc) {
      list = list.reversed.toList();
    }
    return list;
  }

  static List filterList(List list, List<Heading> filterValues) {
    for (var filter in filterValues) {
      if (filter.value != '' ||
          (filter.valueType != "string" && filter.value2!.trim() != '')) {
        switch (filter.valueType) {
          case "string":
            list = list
                .where((x) => x
                    .toMap()[filter.name]
                    .toString()
                    .toLowerCase()
                    .contains(filter.value))
                .toList();
            break;
          case "int":
            if ((int.tryParse(filter.value) != null || filter.value == "") &&
                (int.tryParse(filter.value2!) != null ||
                    filter.value2! == "")) {
              if (filter.value != "" && filter.value2! != "") {
                list = list
                    .where((x) =>
                        x.toMap()[filter.name] <= int.parse(filter.value2!) &&
                        x.toMap()[filter.name] >= int.parse(filter.value))
                    .toList();
              } else if (filter.value != "") {
                list = list
                    .where((x) =>
                        x.toMap()[filter.name] >= int.parse(filter.value))
                    .toList();
              } else if (filter.value2! != "") {
                list = list
                    .where((x) =>
                        x.toMap()[filter.name] <= int.parse(filter.value2!))
                    .toList();
              }
            }
            break;
          case "DateTime":
            bool val1IsDT = DateTime.tryParse(filter.value) != null;
            bool val2IsDT = DateTime.tryParse(filter.value2!) != null;
            if ((val1IsDT || filter.value == "") &&
                (val2IsDT || filter.value2! == "")) {
              if (val1IsDT && val2IsDT) {
                list = list
                    .where((x) =>
                        x
                            .toMap()[filter.name]
                            .isBefore(DateTime.parse(filter.value2!)) &&
                        x
                            .toMap()[filter.name]
                            .isAfter(DateTime.parse(filter.value)))
                    .toList();
              } else if (val1IsDT && filter.value2! == "") {
                list = list
                    .where((x) => x
                        .toMap()[filter.name]
                        .isAfter(DateTime.parse(filter.value)))
                    .toList();
              } else if (val2IsDT && filter.value == "") {
                list = list
                    .where((x) => x
                        .toMap()[filter.name]
                        .isBefore(DateTime.parse(filter.value2!)))
                    .toList();
              }
            }
            break;
          case "double":
            if ((double.tryParse(filter.value) != null || filter.value == "") &&
                (double.tryParse(filter.value2!) != null ||
                    filter.value2! == "")) {
              if (filter.value != "" && filter.value2! != "") {
                list = list
                    .where((x) =>
                        x.toMap()[filter.name] <=
                            double.parse(filter.value2!) &&
                        x.toMap()[filter.name] >= double.parse(filter.value))
                    .toList();
              } else if (filter.value != "") {
                list = list
                    .where((x) =>
                        x.toMap()[filter.name] >= double.parse(filter.value))
                    .toList();
              } else if (filter.value2! != "") {
                list = list
                    .where((x) =>
                        x.toMap()[filter.name] <= double.parse(filter.value2!))
                    .toList();
              }
            }
            break;
          default:
            break;
        }
      }
    }
    return list;
  }
}
