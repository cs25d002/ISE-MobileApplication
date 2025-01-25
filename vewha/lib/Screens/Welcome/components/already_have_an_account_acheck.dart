import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

import 'socal_sign_up.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final Function? press;
  const AlreadyHaveAnAccountCheck({
    Key? key,
    this.login = true, // navigation based on bool val for "is this login page?"
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: 
    [ const SocalSignUp(),
      const SizedBox(height: pad_norm),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            login ? "Don’t have an Account ? " : "Already have an Account ? ",
            style: const TextStyle(color: kPrimaryColor),
          ),
          GestureDetector(
            onTap: press as void Function()?,
            child: Text(
              login ? "Sign Up" : "Sign In",
              style: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),),
          )
        ],)
    ]);
  }
}
