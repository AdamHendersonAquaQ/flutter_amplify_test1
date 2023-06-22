import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:praxis_internals/amplify/env_config.dart';
import 'package:praxis_internals/authentication/authentication_service.dart';

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

var amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "${EnvConfig.poolId1}",
                            "Region": "${EnvConfig.region}"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "${EnvConfig.poolId2}",
                        "AppClientId": "${EnvConfig.appClientId}",
                        "Region": "${EnvConfig.region}"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [
                            "EMAIL"
                        ],
                        "signupAttributes": [],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": [
                                "REQUIRES_LOWERCASE",
                                "REQUIRES_NUMBERS",
                                "REQUIRES_SYMBOLS",
                                "REQUIRES_UPPERCASE"
                            ]
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [
                            "SMS"
                        ],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                }
            }
        }
    }
}''';
