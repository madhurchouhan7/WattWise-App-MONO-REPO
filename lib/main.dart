import 'package:flutter/material.dart';
import 'package:wattwise_app/core/app_theme.dart';
import 'package:wattwise_app/feature/home/screens/home.dart';
import 'package:wattwise_app/feature/splash_screen/splash_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      title: 'WattWise',
      home: Home(),
    );
  }
}
