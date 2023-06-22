import 'package:flutter/material.dart';
import 'package:praxis_internals/colour_constants.dart';

class TemplatePage extends StatelessWidget {
  const TemplatePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: praxisBlue,
      child: Center(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: lightGrey,
            border: Border.all(
              color: darkBlue,
              width: 5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          alignment: Alignment.center,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10), child: child),
        ),
      ),
    ));
  }
}
