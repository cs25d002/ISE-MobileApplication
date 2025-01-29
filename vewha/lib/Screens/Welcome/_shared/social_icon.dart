import 'package:flutter/material.dart';
import 'package:flutter_auth/Components/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocalIcon extends StatelessWidget {
  final String? iconSrc;
  final Function? press;
  const SocalIcon({
    Key? key,
    this.iconSrc,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press as void Function()?,
      child: Container(
        // Outer Decoration
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
          shape: BoxShape.circle,
        ),

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(10),
          // Inner Decoration
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: kPrimaryLightColor,
            ),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            iconSrc!,
            height: 25,
            width: 25,
          ),
        ), // Inner Container
      ), // Outer Container
    );
  }
}
