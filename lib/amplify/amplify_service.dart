import 'package:amplify_flutter/amplify_flutter.dart';

import 'amplifyconfiguration.dart';
import '../authentication/authentication_service.dart';

class AmplifyService {

  static Future<void> configureAmplify() async {
    await _configureAmplify();
  }

  static Future<void> _configureAmplify() async {
    try {
      await AuthenticationService.addAuthPlugin();
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint('An error occurred while configuring Amplify: $e');
    }
  }
}