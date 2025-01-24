import 'package:flutter/material.dart';

import 'or_divider.dart';
import 'social_icon.dart';

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
              iconSrc: "assets/icons/social/google.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "assets/icons/social/facebook.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "assets/icons/social/twitter.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "assets/icons/social/apple.svg",
              press: () {},
            ),
          ],
        ),
      ],
    );
  }
}
