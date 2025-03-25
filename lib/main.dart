import 'package:flutter/material.dart';
//import 'package:mseva/components/home_screen.dart';
import 'package:mseva_punjab/components/starting_screen.dart';
//import 'package:mseva/components/starting_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     title: 'mSeva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StartingScreen(),
    );
  }
}

