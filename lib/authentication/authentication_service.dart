import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  static Logger logger = Logger();
  static Future<void> addAuthPlugin() async {
    try {
      final authPlugin = AmplifyAuthCognito();
      await Amplify.addPlugin(authPlugin);
    } on Exception catch (e) {
      safePrint('An error occurred while configuring Amplify: $e');
    }
  }

  static Future<String> signInUser(String username, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      if (result.nextStep.signInStep ==
          AuthSignInStep.confirmSignInWithNewPassword) {
        return "changePassword";
      }
      return "signedIn";
    } on AuthException catch (e) {
      safePrint(e.message);
      return e.message;
    } catch (e) {
      safePrint(e);
    }
    return "An error has occured while signing in.";
  }

  static Future<SignInResult?> changePasswordOnSignIn(
      String newPassword) async {
    try {
      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: newPassword,
      );
      safePrint(result);
      return (result);
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
    } catch (e) {
      safePrint(e);
    }
    return null;
  }

  static Future<bool> checkSignIn() async {
    try {
      var result = await Amplify.Auth.getCurrentUser();
      safePrint("${result.username} is signed in");
      return (true);
    } on AuthException catch (e) {
      safePrint(e.message);
      return false;
    } catch (e) {
      safePrint(e);
      return false;
    }
  }

  static Future<void> signOutCurrentUser() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      logger.e(e.message);
    }
  }
}
