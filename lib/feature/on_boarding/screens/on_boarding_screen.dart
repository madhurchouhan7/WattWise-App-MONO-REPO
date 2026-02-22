import 'package:flutter/material.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_1.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_2.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_3.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_4.dart';
import 'package:wattwise_app/feature/on_boarding/pages/on_boarding_page_5.dart';

class OnBoardingScreen extends StatefulWidget {
  OnBoardingScreen({super.key});

  final PageController pageController = PageController(initialPage: 0);
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void dispose() {
    widget.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: widget.pageController,
                children: [
                  OnBoardingPage1(pageController: widget.pageController),
                  OnBoardingPage2(pageController: widget.pageController),
                  OnBoardingPage3(pageController: widget.pageController),
                  OnBoardingPage4(pageController: widget.pageController),
                  OnBoardingPage5(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
