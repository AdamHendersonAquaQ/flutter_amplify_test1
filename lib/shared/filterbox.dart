import 'package:flutter/material.dart';

class FilterBox extends StatefulWidget {
  final ValueChanged<int> flipShowFilter;
  final filterValues;
  const FilterBox(
      {super.key, required this.flipShowFilter, required this.filterValues});

  @override
  State<FilterBox> createState() => _FilterState();
}

class _FilterState extends State<FilterBox> {
  Color backgroundColor = Color.fromARGB(255, 192, 192, 192);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: const Color.fromARGB(255, 39, 39, 39),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      "Filter",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        widget.flipShowFilter(1);
                      },
                      child: const Text("Hide Filter"),
                    ))
              ],
            ),
            Table(columnWidths: const {
              0: IntrinsicColumnWidth(),
            }, children: [
              for (var filter in widget.filterValues)
                TableRow(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                    ),
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                          child: Text(
                            "${filter['label']}:",
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            height: 30,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextFormField(
                                initialValue: filter['value'],
                                onChanged: (text) {
                                  filter['value'] = text;
                                },
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15.0),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ])
            ]),
          ],
        ),
      ),
    );
  }
}
