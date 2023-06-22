import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:praxis_internals/amplify/amplify_service.dart';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/amplify/http_client.dart';

class PraxisService {
  static Future<void> configure(String env) async {
    EnvConfig.configureEnv(env);
    NewClient.configureClient();

    await _configureAmplify();
  }

  static Future<void> _configureAmplify() async {
    try {
      await AmplifyService.configureAmplify();
    } on Exception catch (e) {
      safePrint('An error occurred while configuring Amplify: $e');
    }
  }
}
