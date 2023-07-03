import 'package:praxis_internals/authentication/authentication_service.dart';

import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:praxis_internals/pages/auth/newpassword.dart';
import 'package:praxis_internals/pages/auth/shared.dart';
import 'package:praxis_internals/pages/template_page.dart';
import 'package:praxis_internals/colour_constants.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthState();
}

class _AuthState extends State<AuthPage> {
  Future<bool> isLoggedIn() async {
    Future<bool> result = AuthenticationService.checkSignIn();
    bool isLoggedIn = await result;
    if (isLoggedIn) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
    return isLoggedIn;
  }

  @override
  void initState() {
    super.initState();
  }

  var logger = Logger();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var changePassword = false;
  var isLoading = false;
  String? errorLabel;

  void handleSignIn() async {
    setState(() {
      isLoading = true;
    });
    var result = await AuthenticationService.signInUser(
        usernameController.text, passwordController.text);
    if (result == "signedIn") {
      usernameController.clear();
      passwordController.clear();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else if (result == "changePassword") {
      setState(() {
        changePassword = true;
      });
    } else {
      setState(() {
        errorLabel = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  String? validatePassword() {
    return errorLabel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null || snapshot.data) {
            return const TemplatePage(
              child: CircularProgressIndicator(color: praxisGreen),
            );
          } else {
            return TemplatePage(
                child: !changePassword
                    ? Column(children: [
                        Image.asset(
                          'assets/images/praxis_hd.png',
                          package: "praxis_internals",
                          width: 400,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: AuthTextBox(
                              label: "Username",
                              controller: usernameController),
                        ),
                        AuthTextBox(
                          label: "Password",
                          controller: passwordController,
                          validator: validatePassword,
                          onSubmit: handleSignIn,
                        ),
                        isLoading
                            ? const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: CircularProgressIndicator(
                                  color: praxisGreen,
                                ),
                              )
                            : AuthButton(
                                label: "Log in", onPressed: handleSignIn)
                      ])
                    : const NewPasswordSection());
          }
        });
  }
}
