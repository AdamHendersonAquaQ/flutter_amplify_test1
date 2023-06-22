import 'package:flutter/material.dart';
import 'package:praxis_internals/authentication/authentication_service.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/pages/nav_rail.dart';
import 'package:praxis_internals/pages/template_page.dart';

class AuthFrame extends StatefulWidget {
  const AuthFrame({super.key, required this.page, required this.index});
  final Widget page;
  final int index;

  @override
  State<AuthFrame> createState() => _AuthFrameState();
}

class _AuthFrameState extends State<AuthFrame> {
  Future<bool> isLoggedIn() async {
    Future<bool> result = AuthenticationService.checkSignIn();
    bool isLoggedIn = await result;
    if (!isLoggedIn) {
      if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
    }
    return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null || !snapshot.data) {
            return const TemplatePage(
              child: CircularProgressIndicator(color: praxisGreen),
            );
          } else {
            return NavRail(page: widget.page, index: widget.index);
          }
        });
  }
}
