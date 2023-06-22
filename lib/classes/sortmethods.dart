import 'package:praxis_internals/classes/heading.dart';

class SortMethods {
  static List sortList(List list, bool isSortAsc, List<Heading> headings,
      int currentSortColumn) {
    list.sort((a, b) {
      return !isSortAsc
          ? b
              .toMap()[headings[currentSortColumn].name]
              .compareTo(a.toMap()[headings[currentSortColumn].name])
          : a
              .toMap()[headings[currentSortColumn].name]
              .compareTo(b.toMap()[headings[currentSortColumn].name]);
    });
    return list;
  }

  static List isEqualFilter(List list, Heading filter) {
    switch (filter.valueType) {
      case "string":
        list = list
            .where((x) => x
                .toMap()[filter.name]
                .toString()
                .toLowerCase()
                .contains(filter.value.toLowerCase()))
            .toList();
        break;
      case "int":
      case "double":
        if (double.tryParse(filter.value) != null) {
          list = list
              .where((x) =>
                  x.toMap()[filter.name] == double.tryParse(filter.value))
              .toList();
        }
        break;
      case "DateTime":
        if (DateTime.tryParse(filter.value) != null) {
          list = list
              .where((x) =>
                  x
                          .toMap()[filter.name]
                          .difference(DateTime.tryParse(filter.value))
                          .inSeconds ==
                      0 &&
                  x.toMap()[filter.name].second ==
                      DateTime.tryParse(filter.value)!.second)
              .toList();
        }
        break;
    }
    return list;
  }

  static List isBetweenFilter(List list, Heading filter) {
    switch (filter.valueType) {
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
      case "int":
      case "double":
        if ((double.tryParse(filter.value) != null || filter.value == "") &&
            (double.tryParse(filter.value2!) != null || filter.value2! == "")) {
          if (filter.value != "" && filter.value2! != "") {
            list = list
                .where((x) =>
                    x.toMap()[filter.name] != 0 &&
                    x.toMap()[filter.name] <= double.parse(filter.value2!) &&
                    x.toMap()[filter.name] >= double.parse(filter.value))
                .toList();
          } else if (filter.value != "") {
            list = list
                .where((x) =>
                    x.toMap()[filter.name] != 0 &&
                    x.toMap()[filter.name] >= double.parse(filter.value))
                .toList();
          } else if (filter.value2! != "") {
            list = list
                .where((x) =>
                    x.toMap()[filter.name] != 0 &&
                    x.toMap()[filter.name] <= double.parse(filter.value2!))
                .toList();
          }
        }
        break;
      default:
        break;
    }
    return list;
  }

  static List filterList(List list, List<Heading> filterValues) {
    for (var filter in filterValues) {
      if (filter.value != '' ||
          ((filter.comparator == Comparator.isBetween ||
                  filter.comparator == Comparator.isNotBetween) &&
              filter.value2!.trim() != '')) {
        switch (filter.comparator) {
          case Comparator.isEqual:
            list = isEqualFilter(list, filter);
            break;
          case Comparator.isNotEqual:
            List newList = isEqualFilter(list, filter);
            list.removeWhere((x) => newList.contains(x));
            break;
          case Comparator.isBetween:
            list = isBetweenFilter(list, filter);
            break;
          case Comparator.isNotBetween:
            List newList = isBetweenFilter(list, filter);
            list.removeWhere((x) => newList.contains(x));
            break;
          default:
            break;
        }
      }
    }
    return list;
  }

  static List filterSource(List list, String source) {
    return list
        .where((x) => x.source.toLowerCase().contains(source.toLowerCase()))
        .toList();
  }
}
