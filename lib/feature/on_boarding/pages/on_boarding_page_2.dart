import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/on_boarding/widget/use_my_current_location.dart';
import 'package:wattwise_app/feature/welcome/widgets/feature_card.dart';
import 'package:wattwise_app/utils/svg_assets.dart';

class OnBoardingPage2 extends StatelessWidget {
  const OnBoardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> states = [
      'Madhya Predesh',
      'Maharashtra',
      'Rajasthan',
      'Tamil Nadu',
      'Uttar Pradesh',
    ];

    List<String> cities = ['Indore', 'Bhopal', 'Gwalior', 'Jabalpur', 'Ujjain'];
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
                    'Step 2 of 5',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize * 0.65,
                    ),
                  ),

                  SizedBox(height: width * 0.05),

                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Where is your home?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: fontSize * 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'We\'ll use this to fetch accurate electricity rates for your area.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: fontSize * 0.75,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.05),

                  SvgPicture.asset(SvgAssets.location_svg, width: width * 0.4),

                  SizedBox(height: width * 0.05),

                  UseMyCurrentLocation(),

                  SizedBox(height: width * 0.07),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\tState',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        items: states
                            .map(
                              (state) => DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {},
                        hint: Text('Select your State'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: width * 0.03,
                          ),
                        ),
                      ),

                      SizedBox(height: width * 0.05),

                      Text(
                        '\tCity',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        items: cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {},
                        hint: Text('Select your City'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: width * 0.03,
                          ),
                        ),
                      ),

                      SizedBox(height: width * 0.05),

                      Text(
                        '\tElectricity Provider (DISCOM)',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        items:
                            [
                                  'DISCOM 1',
                                  'DISCOM 2',
                                  'DISCOM 3',
                                  'DISCOM 4',
                                  'DISCOM 5',
                                ]
                                .map(
                                  (discom) => DropdownMenuItem(
                                    value: discom,
                                    child: Text(discom),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {},
                        hint: Text('Select your Electricity Provider'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: width * 0.03,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: width * 0.08),

                  CtaButton(text: 'Continue', onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
