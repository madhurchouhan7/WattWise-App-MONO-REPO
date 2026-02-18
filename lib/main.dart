import 'package:flutter/material.dart';
import 'package:wattwise_app/core/app_theme.dart';

void main(List<String> args) {
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
      home: const Scaffold(body: Center(child: Text('Hello, WattWise!'))),
    );
  }
}
