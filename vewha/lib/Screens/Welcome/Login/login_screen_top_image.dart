import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../Components/constants.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Login".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: pad_norm * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Lottie.asset("assets/animations/loginin.json"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: pad_norm * 2),
      ],
    );
  }
}
