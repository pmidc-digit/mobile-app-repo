import 'package:flutter/material.dart';
import 'package:mseva_punjab/components/starting_screen.dart';
import 'package:mseva_punjab/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mSeva Punjab',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const StartingScreen(),
    );
  }
}
