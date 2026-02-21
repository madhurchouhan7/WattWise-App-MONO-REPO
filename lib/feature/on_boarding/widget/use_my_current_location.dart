import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UseMyCurrentLocation extends StatelessWidget {
  const UseMyCurrentLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      // onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.065,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.my_location_rounded,
                color: Theme.of(context).primaryColor,
                size: MediaQuery.of(context).size.width / 600 * 34,
              ),
              SizedBox(width: 12),
              // text
              Text(
                'Use My Current Location',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width / 600 * 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
