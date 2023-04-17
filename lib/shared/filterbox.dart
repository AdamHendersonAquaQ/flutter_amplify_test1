import 'package:flutter/material.dart';
import 'package:flutter_amplify_test/classes/heading.dart';

class FilterBox extends StatefulWidget {
  final ValueChanged<int> flipShowFilter;
  final List<Heading> filterValues;
  const FilterBox(
      {super.key, required this.flipShowFilter, required this.filterValues});

  @override
  State<FilterBox> createState() => _FilterState();
}

bool checkType(String value, String type) {
  if (value == "") return true;
  switch (type) {
    case ("string"):
      return true;
    case ("int"):
      return int.tryParse(value) != null;
    case ("double"):
      return double.tryParse(value) != null;
    case ("DateTime"):
      return DateTime.tryParse(value) != null;
    default:
      return false;
  }
}

class _FilterState extends State<FilterBox> {
  Color backgroundColor = Color.fromARGB(255, 179, 181, 182);
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
        padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
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
            for (var filter in widget.filterValues)
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 7),
                  child: filter.valueType == "string"
                      ? FilterTextBox(
                          filter: filter, value: 1, label: filter.label)
                      : Row(
                          children: [
                            Expanded(
                              child: FilterTextBox(
                                  filter: filter,
                                  value: 1,
                                  label: 'Min ${filter.label}'),
                            ),
                            const Icon(Icons.arrow_right_alt),
                            Expanded(
                              child: FilterTextBox(
                                  filter: filter,
                                  value: 2,
                                  label: 'Max ${filter.label}'),
                            ),
                          ],
                        ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class FilterTextBox extends StatelessWidget {
  const FilterTextBox({
    super.key,
    required this.filter,
    required this.label,
    required this.value,
  });

  final Heading filter;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: checkType(
                  value == 1 ? filter.value : filter.value2!, filter.valueType)
              ? const Color.fromARGB(255, 77, 77, 77)
              : Colors.red,
          width: 1,
        ),
      ),
      height: 30,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: TextFormField(
          initialValue: value == 1 ? filter.value : filter.value2,
          onChanged: (text) {
            if (value == 1) {
              filter.value = text;
            } else {
              filter.value2 = text;
            }
          },
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
