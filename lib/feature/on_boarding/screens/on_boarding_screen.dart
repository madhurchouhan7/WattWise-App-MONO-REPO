import 'package:flutter/material.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_1.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_2.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_3.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_4.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: PageController(initialPage: 0),
                children: const [
                  OnBoardingPage1(),
                  OnBoardingPage2(),
                  OnBoardingPage3(),
                  OnBoardingPage4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
