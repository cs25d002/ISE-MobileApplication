// dependencies
import 'package:flutter/material.dart';
// local refs
import 'or_divider.dart';
import 'social_icon.dart';
import '../../../Services/auth.dart';
import '../../../Components/responsive.dart';
import '../../../Components/constants.dart';

class SocalSignUp extends StatelessWidget {
  const SocalSignUp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        // Use the Responsive class to adjust spacing and sizing
        Responsive(
          mobile: _buildSocialIcons(context, pad_10), // Smaller spacing for mobile
          tablet: _buildSocialIcons(context, pad_20), // Medium spacing for tablet
          desktop: _buildSocialIcons(context, pad_40), // Larger spacing for desktop
        ),
      ],
    );
  }

  // Helper method to build the social icons row with dynamic spacing
  Widget _buildSocialIcons(BuildContext context, double spacing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SocalIcon(
              iconSrc: "assets/images/social/google.svg",
              press: () => AuthMethods.signInWithGoogle(context),
            ),
          ),
          //SizedBox(width: spacing), // Dynamic spacing between icons
          Expanded(
            child: SocalIcon(
              iconSrc: "assets/images/social/facebook.svg",
              press: () {},
            ),
          ),
          //SizedBox(width: spacing), // Dynamic spacing between icons
          Expanded(
            child: SocalIcon(
              iconSrc: "assets/images/social/twitter.svg",
              press: () {},
            ),
          ),
          //SizedBox(width: spacing), // Dynamic spacing between icons
          Expanded(
            child: SocalIcon(
              iconSrc: "assets/images/social/apple.svg",
              press: () {},
            ),
          ),
        ],
      ),
    );
  }
}