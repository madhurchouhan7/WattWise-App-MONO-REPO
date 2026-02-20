import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // <--- MUST BE IMPORTED
import 'package:wattwise_app/feature/home/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ⏳ Wait 3.5 seconds, then Go to Home
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 🎨 1. The Gradient Background (Deep Blue)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Deep Navy
              Color(0xFF2563EB), // Electric Blue
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // 👻 2. The Mascot (Animated)
            Image.asset(
                  'assets/icon/icon_foreground.png', // CHECK THIS PATH matches your pubspec.yaml
                  height: 180,
                )
                .animate(
                  onPlay: (controller) =>
                      controller.repeat(reverse: true), // Loops forever
                )
                .scaleXY(
                  begin: 1.0,
                  end: 1.1,
                  duration: 1.5.seconds,
                  curve: Curves.easeInOut, // Breathing effect
                )
                .rotate(
                  begin: -0.05, // Tilt Left
                  end: 0.05, // Tilt Right
                  duration: 2.seconds,
                  curve: Curves.easeInOut, // Waving effect
                ),

            const SizedBox(height: 30),

            // 📝 3. Title Text (WattWise)
            const Text(
                  "WattWise",
                  style: TextStyle(
                    fontFamily:
                        'Poppins', // Ensure Poppins is in pubspec, or remove this line
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .moveY(begin: 20, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // 📝 4. Tagline Text
            Text(
              "Understand. Reduce. Save.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(
              duration: 800.ms,
              delay: 300.ms,
            ), // Fades in slightly later

            const Spacer(),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
