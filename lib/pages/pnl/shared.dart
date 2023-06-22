import 'package:flutter/material.dart';

class DatePickers extends StatefulWidget {
  const DatePickers({super.key, required this.date, required this.setDate});

  final DateTime date;
  final ValueChanged<DateTime> setDate;

  @override
  State<DatePickers> createState() => _DatePickersState();
}

class _DatePickersState extends State<DatePickers> {
  DateTime? selectedDate;
  final DateTime _firstDate = DateTime(DateTime.now().year - 1);
  final DateTime _lastDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: TextButton(
        onPressed: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: widget.date,
            firstDate: _firstDate,
            lastDate: _lastDate,
          );
          if (date != null) {
            widget.setDate(date);
          }
          setState(() {
            selectedDate = date;
          });
        },
        child:
            const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Text(
              'Change Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.calendar_month),
        ]),
      ),
    );
  }
}

class PnLSegmentedButton extends StatefulWidget {
  const PnLSegmentedButton(
      {super.key,
      required this.selectedCalender,
      required this.setSelectedCalender});

  final int selectedCalender;
  final ValueChanged<int> setSelectedCalender;

  @override
  State<PnLSegmentedButton> createState() => _PnLSegmentedButtonState();
}

class _PnLSegmentedButtonState extends State<PnLSegmentedButton> {
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
            value: 0,
            label: Text('Daily'),
            icon: Icon(Icons.calendar_view_day)),
        ButtonSegment<int>(
            value: 1,
            label: Text('Monthly'),
            icon: Icon(Icons.calendar_view_month)),
      ],
      selected: <int>{widget.selectedCalender},
      onSelectionChanged: (newSelection) {
        setState(() {
          widget.setSelectedCalender(newSelection.first);
        });
      },
    );
  }
}
