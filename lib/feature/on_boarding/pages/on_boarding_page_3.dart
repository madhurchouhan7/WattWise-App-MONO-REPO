import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/on_boarding/widget/family_type.dart';
import 'package:wattwise_app/feature/on_boarding/widget/people_select.dart';
import 'package:wattwise_app/feature/on_boarding/widget/use_my_current_location.dart';
import 'package:wattwise_app/utils/svg_assets.dart';

class OnBoardingPage3 extends StatelessWidget {
  final PageController pageController;
  const OnBoardingPage3({super.key, required this.pageController});

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
                    'Step 3 of 5',
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
                        'How many People live with you?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: fontSize * 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'This helps us estimate typical electricity usage for your household.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: fontSize * 0.75,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.05),

                  SvgPicture.asset(
                    SvgAssets.people_home_svg,
                    width: width * 0.4,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PeopleSelect(text: '-'),
                      Column(
                        children: [
                          Text(
                            '2',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 3,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          Text(
                            'People',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.75,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      PeopleSelect(text: '+'),
                    ],
                  ),

                  SizedBox(height: width * 0.05),

                  Wrap(
                    spacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(
                        labelStyle: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          color: Colors.black,
                        ),
                        label: Text('Just Me'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Chip(
                         
                        labelStyle: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          color: Colors.black,
                        ),
                        label: Text('Small Family'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Chip(
                        labelStyle: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          color: Colors.black,
                        ),
                        label: Text('Large Family'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Chip(
                        labelStyle: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          color: Colors.black,
                        ),
                        label: Text('Join Family'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: width * 0.07),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\tMore Details(optional)',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize * 0.75,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        items: ['1', '2', '3', '4', '5+']
                            .map( 
                              (state) => DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {},
                        hint: Text('HOUSE TYPE'),
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

                      SizedBox(height: width * 0.05),
                    ],
                  ),

                  SizedBox(height: width * 0.08),

                  CtaButton(text: 'Continue', onPressed: () {
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
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
