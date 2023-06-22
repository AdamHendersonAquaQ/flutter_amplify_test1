import 'package:flutter/material.dart';

import 'package:praxis_internals/pages/auth/shared.dart';
import 'package:praxis_internals/pages/template_page.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage(
      {super.key, required this.label, required this.destination});

  final String label;
  final String destination;

  @override
  Widget build(BuildContext context) {
    void goToLogin() {
      Navigator.of(context).pushReplacementNamed('/$destination');
    }

    return TemplatePage(
      child: Column(children: [
        Image.asset(
          'assets/images/praxis_hd.png',
          package: "praxis_internals",
          width: 400,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 70),
          child: Text(
            "You do not have permission to access this page",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        AuthButton(label: label, onPressed: goToLogin)
      ]),
    );
  }
}
