import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../Components/constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Sign Up".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: pad_norm),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Lottie.asset(
              "assets/animations/signin.json"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: pad_norm),
      ],
    );
  }
}
