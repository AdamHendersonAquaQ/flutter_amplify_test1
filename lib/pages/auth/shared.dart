import 'package:flutter/material.dart';
import 'package:praxis_internals/colour_constants.dart';

class AuthTextBox extends StatelessWidget {
  const AuthTextBox(
      {super.key,
      required this.label,
      required this.controller,
      this.validator,
      this.onSubmit});

  final String label;
  final TextEditingController controller;
  final ValueGetter<String?>? validator;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    bool isPassword = label != "Username";

    const regularBorder = OutlineInputBorder(
      borderSide: BorderSide.none,
    );
    const errorBorder = OutlineInputBorder(
        borderSide: BorderSide(
      width: 2,
      color: Colors.red,
    ));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, top: 10),
              child: Icon(
                isPassword ? Icons.lock : Icons.account_circle,
                size: 40,
                color: offWhite,
              ),
            ),
            SizedBox(
              width: 280,
              child: TextFormField(
                style: const TextStyle(fontSize: 18, color: Colors.black),
                obscureText: isPassword,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: offWhite,
                  enabledBorder: regularBorder,
                  border: regularBorder,
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                  errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
                  hintText: label,
                  hintStyle: const TextStyle(fontSize: 16, color: mediumGrey),
                ),
                controller: controller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  return isPassword ? validator!() : null;
                },
                onFieldSubmitted: (value) {
                  if (onSubmit != null) {
                    onSubmit!();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: ElevatedButton(
              onPressed: () => onPressed(),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(praxisGreen),
                  foregroundColor: MaterialStateProperty.all(praxisBlue),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
              child: SizedBox(
                height: 50,
                width: 300,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
