import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/heading.dart';

class NewTable extends StatefulWidget {
  final int currentSortColumn;
  final ValueChanged<int> setSortColumn;
  final bool isSortAsc;
  final ValueChanged<bool> setIsSortAsc;

  final List<Heading> headings;
  final List data;
  const NewTable(
      {super.key,
      required this.currentSortColumn,
      required this.isSortAsc,
      required this.headings,
      required this.data,
      required this.setSortColumn,
      required this.setIsSortAsc});

  @override
  State<NewTable> createState() => _NewTableState();
}

class _NewTableState extends State<NewTable> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
              color: const Color.fromARGB(255, 75, 75, 75),
              child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    dataRowHeight: 35,
                    headingRowHeight: 35,
                    showBottomBorder: true,
                    columnSpacing: 0,
                    horizontalMargin: 0,
                    border: TableBorder.all(
                      width: 1,
                      color: const Color.fromARGB(255, 65, 65, 65),
                    ),
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.black),
                    sortColumnIndex: widget.currentSortColumn,
                    sortAscending: widget.isSortAsc,
                    columns: [
                      for (var heading in widget.headings)
                        DataColumn(
                          label: Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 35),
                                child: Row(children: [
                                  Expanded(
                                    child: Text(
                                      heading.label,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (widget.currentSortColumn ==
                                      widget.headings.indexOf(heading))
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                          widget.isSortAsc
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: Colors.blue,
                                          size: 20),
                                    )
                                  else
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(Icons.arrow_downward,
                                          color: Colors.black, size: 20),
                                    )
                                ]),
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
                          },
                        ),
                    ],
                    rows: [
                      for (var pos in widget.data)
                        DataRow(
                            color: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (widget.data.indexOf(pos) % 2 == 0) {
                                return const Color.fromARGB(255, 130, 174, 189)
                                    .withOpacity(0.3);
                              }
                              return const Color.fromARGB(255, 116, 116, 116);
                            }),
                            cells: [
                              for (var heading in widget.headings)
                                heading.headingType == "text"
                                    ? DataCell(
                                        Center(
                                          child: SelectableText(
                                            pos
                                                .toMap()[heading.name]
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : DataCell(
                                        Container(
                                          color: pos.toMap()[heading.name] >= 0
                                              ? Colors.green
                                              : Colors.red,
                                          child: Center(
                                            child: SelectableText(
                                              pos
                                                  .toMap()[heading.name]
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                            ]),
                    ],
                  ))),
        ),
      ),
    );
  }
}
