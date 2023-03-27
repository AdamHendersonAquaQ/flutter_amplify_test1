import 'package:flutter/material.dart';

class CenteredCell extends StatefulWidget {
  final String cellText;
  const CenteredCell({super.key, required this.cellText});
  @override
  State<CenteredCell> createState() => _CenteredCellState();
}

class _CenteredCellState extends State<CenteredCell> {
  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          widget.cellText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      )),
    );
  }
}
