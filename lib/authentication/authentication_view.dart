import 'package:flutter/material.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

class AuthenticationView extends Authenticator {
  AuthenticationView({super.key, required child}) : super(child: child);

  static TransitionBuilder builder() {
    return Authenticator.builder();
  }
}
