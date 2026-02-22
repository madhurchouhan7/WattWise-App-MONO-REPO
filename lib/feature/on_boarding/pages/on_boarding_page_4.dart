import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/on_boarding/provider/selected_appliance_notifier.dart';
import 'package:wattwise_app/feature/on_boarding/widget/family_type.dart';
import 'package:wattwise_app/feature/on_boarding/widget/people_select.dart';
import 'package:wattwise_app/feature/on_boarding/widget/select_appliances.dart';
import 'package:wattwise_app/feature/on_boarding/widget/use_my_current_location.dart';
import 'package:wattwise_app/utils/svg_assets.dart';

class OnBoardingPage4 extends ConsumerWidget {
  final PageController pageController;
  const OnBoardingPage4({super.key, required this.pageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the selected count
    final selectedCount = ref.watch(
      selectedAppliancesProvider.select((appliances) => appliances.length),
    );
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width * 0.05;
    return LayoutBuilder(
      builder: (context, constraints) {
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

                  TextButton(
                    onPressed: () {
                      // Clear selections and skip
                      ref.read(selectedAppliancesProvider.notifier).clearAll();
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('Skip Setup'),
                  ),
                ],
              ),
            ),

            // scrollable content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: width * 0.25),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: width * 0.02,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Step 4 of 5',
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
                                'Select Your Appliances',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: fontSize * 1.3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                'Check the ones you have at home. this helps us identify where you can save.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: fontSize * 0.75,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: width * 0.05),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // cooling
                              Text(
                                'COOLING',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SelectAppliances(
                                title: 'Air Conditioner',
                                description: 'Split AC, Window AC, Inverter',
                                svgPath: SvgAssets.ac_icon,
                                category: 'COOLING',
                              ),

                              SelectAppliances(
                                title: 'Air Cooler',
                                description: 'Desert, Personal, Tower',
                                svgPath: SvgAssets.wind_icon,
                                category: 'COOLING',
                              ),

                              // HEATING
                              Text(
                                'HEATING',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SelectAppliances(
                                title: 'Geyser',
                                description: 'Electric, Gas, Instant',
                                svgPath: SvgAssets.geyser_icon,
                                category: 'HEATING',
                              ),

                              SelectAppliances(
                                title: 'Room Heater',
                                description: 'Fan, Oil, Halogen',
                                svgPath: SvgAssets.room_heater_icon,
                                category: 'HEATING',
                              ),

                              // always on
                              Text(
                                'ALWAYS ON',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SelectAppliances(
                                title: 'Refridgerator',
                                description: 'Single, Double Door',
                                svgPath: SvgAssets.fridge_icon,
                                category: 'ALWAYS ON',
                              ),

                              SelectAppliances(
                                title: 'Television',
                                description: 'LCD, LED, Smart',
                                svgPath: SvgAssets.tv_icon,
                                category: 'ALWAYS ON',
                              ),

                              SelectAppliances(
                                title: 'Wi-Fi Router',
                                description: 'Modem, Extender',
                                svgPath: SvgAssets.wifi_router_icon,
                                category: 'ALWAYS ON',
                              ),

                              // OCCASIONAL USE
                              Text(
                                'OCCASIONAL USE',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SelectAppliances(
                                title: 'Washing Machine',
                                description: 'Front Load, Top Load',
                                svgPath: SvgAssets.washing_machine_icon,
                                category: 'OCCASIONAL USE',
                              ),

                              SelectAppliances(
                                title: 'Microwave Oven',
                                description: 'Solo, Grill, Convection',
                                svgPath: SvgAssets.microwave_icon,
                                category: 'OCCASIONAL USE',
                              ),

                              SelectAppliances(
                                title: 'Water Purifier',
                                description: 'RO, UV',
                                svgPath: SvgAssets.water_purifier_icon,
                                category: 'OCCASIONAL USE',
                              ),

                              SelectAppliances(
                                title: 'Computer',
                                description: 'Desktop, Workstation',
                                svgPath: SvgAssets.computer_icon,
                                category: 'OCCASIONAL USE',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(width * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: CtaButton(
                        text: selectedCount > 0 
                            ? 'Continue, $selectedCount Selected' 
                            : 'Select at least one',
                        onPressed: selectedCount > 0 
                            ? () {
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
