import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import '../../../Components/constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "WELCOME TO VEWHA",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: pad_norm * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Lottie.asset(
                "assets/animations/start.json",
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: pad_norm * 2),
      ],
    );
  }
}
