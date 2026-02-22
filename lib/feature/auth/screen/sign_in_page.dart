import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wattwise_app/feature/auth/screen/sign_up_page.dart';
import 'package:wattwise_app/feature/auth/widgets/cta_button.dart';
import 'package:wattwise_app/feature/auth/widgets/sign_in_with_google.dart';
import 'package:wattwise_app/feature/on_boarding/screens/on_boarding_screen.dart';
import 'package:wattwise_app/utils/svg_assets.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final fontSize = screenWidth * 0.05;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(fontSize * 0.75),
                child: Column(
                  children: [
                    // welcome text
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: fontSize * 1.45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: fontSize * 0.4),

                            Text(
                              'Sign in to continue',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: fontSize * 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // svg
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: fontSize * 1.2),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/svg/sign_in_overlay.png',
                          width: screenWidth * 0.5,
                          height: screenWidth * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // sign in form :
                    // email field
                    TextFormField(
                      style: GoogleFonts.nunito(color: Colors.black),
                      key: ValueKey('email'),

                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 15, right: 5),
                          child: Icon(Icons.email, color: Colors.grey),
                        ),
                        hintText: "Enter Address",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),

                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // password field
                    SizedBox(height: fontSize * 0.5),

                    TextFormField(
                      style: GoogleFonts.nunito(color: Colors.black),
                      key: ValueKey('password'),

                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 15, right: 5),
                          child: Icon(Icons.lock, color: Colors.grey),
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),

                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    SizedBox(height: fontSize * 1.5),

                    // OR
                    Row(
                      children: [
                        // line
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),

                        // or
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: fontSize * 0.5,
                          ),
                          child: Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.8,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),

                        // line
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),

                    SizedBox(height: fontSize * 1.5),

                    // continue with google
                    const SignInWithGoogle(svgAssets: SvgAssets.google_svg),

                    // forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.75,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: fontSize * 2),

                    // CTA : sign in
                    CtaButton(
                      text: 'Sign In',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnBoardingScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: fontSize * 1),

                    // dont have an account? sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: GoogleFonts.poppins(
                            fontSize: fontSize * 0.75,
                            color: Colors.grey[600],
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.75,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
