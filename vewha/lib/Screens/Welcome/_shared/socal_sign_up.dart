// dependencies
import 'package:flutter/material.dart';
// local refs
import 'or_divider.dart';
import 'social_icon.dart';
import '../../../Services/auth.dart';

class SocalSignUp extends StatelessWidget {
  const SocalSignUp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SocalIcon(
              iconSrc: "icons/social/google.svg",
              press: () => AuthMethods.signInWithGoogle(context),
            ),
            SocalIcon(
              iconSrc: "icons/social/facebook.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "icons/social/twitter.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "icons/social/apple.svg",
              press: () {},
            ),
          ],
        ),
      ],
    );
  }
}
