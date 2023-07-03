import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praxis_internals/classes/heading.dart';
import 'package:praxis_internals/colour_constants.dart';

class NewTable extends StatefulWidget {
  final int currentSortColumn;
  final ValueChanged<int> setSortColumn;
  final bool isSortAsc;
  final ValueChanged<bool> setIsSortAsc;

  final List data;
  final VoidCallback setData;
  final List<Heading> headings;

  final bool paged;
  final bool? isDashboard;

  const NewTable(
      {super.key,
      required this.currentSortColumn,
      required this.setSortColumn,
      required this.isSortAsc,
      required this.setIsSortAsc,
      required this.data,
      required this.setData,
      required this.headings,
      required this.paged,
      this.isDashboard});
  @override
  State<NewTable> createState() => _NewTableState();
}

DataRow tableRow(pos, data, headings, bool? isSmall) {
  return DataRow(
      color:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (pos % 2 == 0) {
          return const Color.fromARGB(180, 141, 186, 201);
        }
        return const Color.fromARGB(180, 149, 156, 158);
      }),
      cells: [
        for (var heading in headings)
          DataCell((heading.name == "latestPrice" &&
                  data[pos].toMap()[heading.name] == 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                    ),
                    child: textCell(data[pos], heading, isSmall ?? false),
                  ),
                )
              : heading.name == "value"
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: data[pos].nett >= 0
                              ? Colors.green.withOpacity(0.8)
                              : Colors.red.withOpacity(0.8),
                        ),
                        child: textCell(data[pos], heading, isSmall ?? false),
                      ),
                    )
                  : (heading.headingType == "text"
                      ? textCell(data[pos], heading, isSmall ?? false)
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: data[pos].toMap()[heading.name] >= 0 &&
                                      heading.name != "latestPrice"
                                  ? Colors.green.withOpacity(0.8)
                                  : Colors.red.withOpacity(0.8),
                            ),
                            child:
                                textCell(data[pos], heading, isSmall ?? false),
                          ),
                        ))))
      ]);
}

NumberFormat numberFormat = NumberFormat("#,##0.00###", "en_US");
List<String> numFormatList = ["latestPrice", "lastPrice"];
NumberFormat numberFormatThreeDec = NumberFormat("#,##0.###", "en_US");
List<String> threeDecFormatList = ["value"];
NumberFormat numberFormatOneDec = NumberFormat("#,##0.#", "en_US");
List<String> oneDecFormatList = ["quantity"];
NumberFormat numberFormatNoDec = NumberFormat("#,##0", "en_US");
List<String> noDecFormatList = ["position", "hedge", "nett"];

Center textCell(pos, Heading heading, bool isSmall) {
  var text = pos.toMap()[heading.name];

  var textStyle = TextStyle(fontSize: isSmall ? 11 : 14);
  return Center(
    child: heading.name != "transactionTime"
        ? SelectableText(
            text == 0 && heading.name == "latestPrice"
                ? " "
                : numFormatList.contains(heading.name)
                    ? numberFormat.format(text)
                    : threeDecFormatList.contains(heading.name)
                        ? numberFormatThreeDec.format(text)
                        : oneDecFormatList.contains(heading.name)
                            ? numberFormatOneDec.format(text)
                            : noDecFormatList.contains(heading.name)
                                ? numberFormatNoDec.format(text.round())
                                : pos.toMap()[heading.name].toString(),
            style: textStyle,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 2),
                child: SizedBox(
                  width: 10,
                  child: pos.toMap()["source"] != "Onezero"
                      ? const Tooltip(
                          message: "* = Hedge\n   = Client",
                          child: Text(
                            "*",
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : const Text(
                          "",
                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ),
              SelectableText(
                pos.toMap()[heading.name].toString(),
                style: textStyle,
              ),
              const Text("")
            ],
          ),
  );
}

class MyData extends DataTableSource {
  List data;
  List<Heading> headings;

  MyData({required this.data, required this.headings});

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return tableRow(index, data, headings, null);
  }
}

class _NewTableState extends State<NewTable> {
  double rowHeight = 25;
  @override
  Widget build(BuildContext context) {
    bool isSmall = (widget.isDashboard != null) &&
        MediaQuery.of(context).size.width < 1500 &&
        widget.headings.length >= 5;
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SizedBox(
              width: double.infinity,
              child: widget.paged
                  ? PaginatedDataTable(
                      showFirstLastButtons: true,
                      dataRowMaxHeight: rowHeight,
                      dataRowMinHeight: rowHeight,
                      headingRowHeight: 30,
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      sortColumnIndex: widget.currentSortColumn,
                      sortAscending: widget.isSortAsc,
                      columns: [
                        for (var heading in widget.headings)
                          tableColumn(heading, isSmall),
                      ],
                      source: MyData(
                        data: widget.data,
                        headings: widget.headings,
                      ),
                      arrowHeadColor: praxisGreen,
                      rowsPerPage: ((MediaQuery.of(context).size.height /
                                      (widget.isDashboard != null ? 2 : 1) -
                                  168.5) /
                              rowHeight)
                          .floor(),
                    )
                  : DataTable(
                      dataRowMaxHeight: rowHeight,
                      dataRowMinHeight: rowHeight,
                      headingRowHeight: 30,
                      showBottomBorder: true,
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => Theme.of(context).cardColor),
                      sortColumnIndex: widget.currentSortColumn,
                      sortAscending: widget.isSortAsc,
                      columns: [
                        for (var heading in widget.headings)
                          tableColumn(heading, isSmall)
                      ],
                      rows: [
                        for (var pos in widget.data)
                          tableRow(widget.data.indexOf(pos), widget.data,
                              widget.headings, isSmall),
                      ],
                    ),
            )),
      ),
    );
  }

  DataColumn tableColumn(Heading heading, bool isSmall) {
    return DataColumn(
      label: Expanded(
        child: Center(
          child: Text(
            heading.label,
            style: TextStyle(fontSize: isSmall ? 13 : 14),
          ),
        ),
      ),
      onSort: (columnIndex, _) {
        setState(() {
          if (widget.currentSortColumn == columnIndex) {
            widget.setIsSortAsc(!widget.isSortAsc);
          } else {
            widget.setSortColumn(columnIndex);
            widget.setIsSortAsc(false);
          }
        });
        widget.setData();
      },
    );
  }
}
