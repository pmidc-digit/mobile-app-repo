import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_new_app/components/starting_screen.dart';
import 'package:permission_handler/permission_handler.dart';

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
