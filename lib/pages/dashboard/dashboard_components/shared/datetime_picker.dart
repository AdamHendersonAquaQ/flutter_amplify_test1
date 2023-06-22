import 'package:flutter/material.dart';
import 'package:praxis_internals/classes/heading.dart';

typedef MyEventCallback = void Function(DateTime newDate);

class DateTimePicker extends StatefulWidget {
  const DateTimePicker(
      {super.key,
      required this.heading,
      required this.date,
      required this.setDate});

  final Heading heading;
  final MyEventCallback setDate;
  final DateTime date;

  @override
  State<DateTimePicker> createState() => _DatePickersState();
}

class _DatePickersState extends State<DateTimePicker> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    DateTime initialDate =
        DateTime.tryParse(widget.heading.value) ?? widget.date;
    if (initialDate.isAfter(widget.date)) initialDate = widget.date;
    return IconButton(
      iconSize: 23,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: widget.date.subtract(const Duration(days: 1)),
          lastDate: widget.date,
        );
        if (date != null) {
          if (context.mounted) {
            TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(
                  DateTime.tryParse(widget.heading.value) ?? DateTime.now()),
              orientation: Orientation.portrait,
              builder: (BuildContext context, Widget? child) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      alwaysUse24HourFormat: true,
                    ),
                    child: child!,
                  ),
                );
              },
            );
            if (time != null) {
              date = date.copyWith(minute: time.minute, hour: time.hour);
            }
          }
          widget.setDate(date);
        }
        setState(() {
          selectedDate = date;
        });
      },
      icon: const Icon(Icons.calendar_month),
    );
  }
}
