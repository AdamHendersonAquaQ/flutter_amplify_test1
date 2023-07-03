import 'package:praxis_internals/classes/pnl.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class PnLWidget extends StatefulWidget {
  const PnLWidget({super.key, required this.data, required this.label});

  final String label;
  final PnL data;

  @override
  State<PnLWidget> createState() => _PnLWidgetState();
}

class _PnLWidgetState extends State<PnLWidget> {
  final cy = NumberFormat("#,##0.000", "en_US");

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Text(
              "${widget.label} PnL:",
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Icon(
            size: 18,
            widget.data.sum > 0
                ? Icons.keyboard_arrow_up_outlined
                : Icons.keyboard_arrow_down_outlined,
            color: widget.data.sum == 0
                ? Theme.of(context).scaffoldBackgroundColor
                : widget.data.sum > 0
                    ? Colors.green
                    : Colors.red,
          ),
          Tooltip(
            message: widget.data.previousSum == null
                ? "No Previous value available"
                : "Previous: \$${cy.format(widget.data.previousSum)}",
            child: SelectableText(
              '\$${cy.format(widget.data.sum)}',
              style: TextStyle(
                color: widget.data.sum == 0
                    ? Colors.white
                    : widget.data.sum > 0
                        ? Colors.green
                        : Colors.red,
                fontSize: 18,
              ),
            ),
          ),
        ]);
  }
}
