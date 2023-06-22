import 'package:flutter/material.dart';
import 'package:praxis_internals/authentication/authentication_service.dart';
import 'package:praxis_internals/pages/auth/shared.dart';
import 'package:praxis_internals/colour_constants.dart';

class NewPasswordSection extends StatefulWidget {
  const NewPasswordSection({super.key});

  @override
  State<NewPasswordSection> createState() => _NewPasswordSectionState();
}

class _NewPasswordSectionState extends State<NewPasswordSection> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    String? validateNewPassword() {
      if (!RegExp(r'[A-Z]').hasMatch(passwordController.text)) {
        return "Password should contain a capital letter";
      } else if (!RegExp(r'[a-z]').hasMatch(passwordController.text)) {
        return "Password should contain a lower case letter";
      } else if (!RegExp(r'\d').hasMatch(passwordController.text)) {
        return "Password should contain a number";
      } else if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(passwordController.text)) {
        return "Password should contain a special character";
      } else if (passwordController.text.length < 8) {
        return "Password should be longer than 8";
      } else {
        return null;
      }
    }

    String? validateConfirmPassword() {
      if (confirmPasswordController.text != passwordController.text) {
        return "Passwords must match.";
      } else {
        return null;
      }
    }

    void handleChange() async {
      if (validateNewPassword() == null && validateConfirmPassword() == null) {
        setState(() {
          isLoading = true;
        });
        var result = await AuthenticationService.changePasswordOnSignIn(
            passwordController.text);

        if (result!.isSignedIn && context.mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
        setState(() {
          isLoading = false;
        });
      }
    }

    return isLoading
        ? const Padding(
            padding: EdgeInsets.only(top: 30),
            child: CircularProgressIndicator(
              color: praxisGreen,
            ),
          )
        : Column(
            children: [
              Image.asset(
                'assets/images/praxis_hd.png',
                //package: "praxis_internals",
                width: 400,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Set new password to log in:",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              AuthTextBox(
                label: "New Password",
                controller: passwordController,
                validator: validateNewPassword,
              ),
              AuthTextBox(
                label: "Confirm New Password",
                controller: confirmPasswordController,
                validator: validateConfirmPassword,
                onSubmit: handleChange,
              ),
              AuthButton(
                label: "Change Password",
                onPressed: handleChange,
              )
            ],
          );
  }
}
