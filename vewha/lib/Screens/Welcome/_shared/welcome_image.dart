import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Components/constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

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
              child: SvgPicture.asset(
                "assets/images/login/chat.svg",
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