import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/welcome/widgets/feature_card.dart';
import 'package:wattwise_app/utils/svg_assets.dart';

class OnBoardingPage1 extends StatelessWidget {
  final PageController pageController;

  const OnBoardingPage1({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width * 0.05;
    return Column(
      children: [
        // fixed row at the top
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: width * 0.02,
          ),
          child: Row(
            children: [
              // TODO: Add Progress Indicator here
              Placeholder(fallbackHeight: 10, fallbackWidth: 100),

              Spacer(),

              TextButton(onPressed: () {}, child: Text('Skip Setup')),
            ],
          ),
        ),

        // scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: width * 0.02,
              ),
              child: Column(
                children: [
                  Text(
                    'Step 1 of 5',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize * 0.65,
                    ),
                  ),

                  SizedBox(height: width * 0.05),

                  Image.asset(
                    'assets/svg/onboarding_1.png',
                    width: width * 0.8,
                  ),

                  SizedBox(height: width * 0.05),

                  Wrap(
                    children: [
                      Text(
                        'Let\'s Set Up Your Profile',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: fontSize * 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: width * 0.07),

                  // your location card
                  FeatureCard(
                    title: 'Your Location',
                    description: 'So we can use accurate \nElectricity Rates',
                    svgIcon: SvgAssets.location_icon,
                  ),

                  // household size card
                  FeatureCard(
                    title: 'Household Size',
                    description: 'To estimate your typical Usage',
                    svgIcon: SvgAssets.group_icon,
                  ),

                  // your appliances card
                  FeatureCard(
                    title: 'Your Appliances',
                    description: 'To Identify saving opportunities',
                    svgIcon: SvgAssets.shop_icon,
                  ),

                  // use pattern card
                  FeatureCard(
                    title: 'Usage Patterns',
                    description: 'For Personalized Saving Plans',
                    svgIcon: SvgAssets.insights_icon,
                  ),

                  SizedBox(height: width * 0.05),

                  CtaButton(text: 'Lets Go!', onPressed: () {
                    pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
