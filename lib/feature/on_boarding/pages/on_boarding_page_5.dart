import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingPage5 extends StatelessWidget {
  const OnBoardingPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fontSize = width * 0.05;

        return Column(
          children: [
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

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            'ALMOST DONE! 🎉',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: fontSize * 0.65,
                            ),
                          ),
                          SizedBox(height: width * 0.05),

                          Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              Text(
                                'How often do you use these?',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: fontSize * 1.3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: width * 0.05),

                              Text(
                                'Tell us about your daily usage for these key appliances. You can always update this later in your Settings',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: fontSize * 0.7,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
