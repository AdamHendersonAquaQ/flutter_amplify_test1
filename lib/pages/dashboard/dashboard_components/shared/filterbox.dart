import 'package:flutter/material.dart';
import 'package:praxis_internals/classes/heading.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/datetime_picker.dart';

class FilterBox extends StatefulWidget {
  final List<Heading> filterValues;
  final VoidCallback filterMethod;
  final DateTime? date;
  const FilterBox(
      {super.key,
      required this.filterValues,
      required this.filterMethod,
      this.date});

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

const List<Comparator> list = <Comparator>[
  Comparator.isEqual,
  Comparator.isNotEqual,
  Comparator.isBetween,
  Comparator.isNotBetween
];

class _FilterState extends State<FilterBox> {
  void resetFilters() {
    for (Heading filter in widget.filterValues) {
      filter.value = "";
      if (filter.value2 != null) {
        filter.value2 = "";
      }
    }
    setState(() {
      widget.filterMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var filter in widget.filterValues)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 210,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 3),
                        child: Text(
                          filter.label.trim(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      dropdown(filter)
                    ],
                  ),
                ),
                filter.comparator.toString().contains("Equal")
                    ? FilterTextBox(
                        filter: filter,
                        value: 1,
                        label: filter.label,
                        filterMethod: widget.filterMethod,
                        date: widget.date,
                      )
                    : FilterRangeBox(
                        filter: filter,
                        filterMethod: widget.filterMethod,
                        date: widget.date,
                      ),
              ],
            ),
          SizedBox(
            width: 90,
            child: TextButton(
                onPressed: () => resetFilters(),
                child: const Row(
                    children: [Text("Reset"), Icon(Icons.refresh_outlined)])),
          )
        ],
      ),
    );
  }

  Padding dropdown(Heading filter) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 3),
      child: DropdownButton<Comparator>(
        isDense: true,
        value: filter.comparator,
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        onChanged: (Comparator? value) {
          setState(() {
            filter.comparator = value!;
          });
          widget.filterMethod();
        },
        items: list
            .sublist(0, filter.valueType == "string" ? 2 : 4)
            .map<DropdownMenuItem<Comparator>>((Comparator value) {
          return DropdownMenuItem<Comparator>(
            value: value,
            child: Text(value.name
                .replaceAll("is", "Is ")
                .replaceAll("Not", "Not ")
                .replaceAll("Equal", "Equal to")),
          );
        }).toList(),
      ),
    );
  }
}

class FilterRangeBox extends StatelessWidget {
  const FilterRangeBox(
      {super.key, required this.filter, required this.filterMethod, this.date});

  final Heading filter;
  final VoidCallback filterMethod;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterTextBox(
          filter: filter,
          value: 1,
          label: 'Min ${filter.label}',
          filterMethod: filterMethod,
          date: date,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(
            Icons.arrow_right_alt,
          ),
        ),
        FilterTextBox(
          filter: filter,
          value: 2,
          label: 'Max ${filter.label}',
          filterMethod: filterMethod,
          date: date,
        ),
      ],
    );
  }
}

class FilterTextBox extends StatefulWidget {
  const FilterTextBox(
      {super.key,
      required this.filter,
      required this.label,
      required this.value,
      required this.filterMethod,
      this.date});

  final Heading filter;
  final String label;
  final int value;
  final VoidCallback filterMethod;
  final DateTime? date;

  @override
  State<FilterTextBox> createState() => _FilterTextBoxState();
}

class _FilterTextBoxState extends State<FilterTextBox> {
  final errorBorder = const OutlineInputBorder(
      borderSide: BorderSide(
    width: 2,
    color: Colors.red,
  ));

  @override
  Widget build(BuildContext context) {
    TextEditingController contr = TextEditingController(
        text: widget.value == 1 ? widget.filter.value : widget.filter.value2);
    contr.selection =
        TextSelection.fromPosition(TextPosition(offset: contr.text.length));

    void setVal(String val) {
      if (widget.value == 1) {
        widget.filter.value = val;
      } else {
        widget.filter.value2 = val;
      }
      widget.filterMethod();
    }

    void setDate(DateTime date) {
      setVal(date.toString());
      setState(() {
        contr.text =
            (widget.value == 1 ? widget.filter.value : widget.filter.value2)!;
      });
    }

    return SizedBox(
      height: 65,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: !widget.filter.comparator.toString().contains("Between")
                ? 210
                : (widget.filter.valueType == "DateTime" ? 165 : 185),
            child: TextFormField(
              controller: contr,
              onChanged: (text) => setVal(text),
              textAlignVertical: TextAlignVertical.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (val) {
                return !checkType(val!, widget.filter.valueType)
                    ? "Invalid parameter type"
                    : null;
              },
              decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                  errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.label,
                  hintStyle: const TextStyle(fontSize: 14, color: mediumGrey),
                  contentPadding: const EdgeInsets.fromLTRB(7, 5, 7, 10),
                  suffix: IconButton(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.close,
                      size: 22,
                      color: mediumGrey,
                    ),
                    onPressed: () => {
                      setVal(""),
                      setState(() {
                        contr.clear();
                      })
                    },
                  )),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
          widget.filter.valueType == "DateTime"
              ? Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: DateTimePicker(
                    heading: widget.filter,
                    date: widget.date ?? DateTime.now(),
                    setDate: setDate,
                  ),
                )
              : const Text(""),
        ],
      ),
    );
  }
}
