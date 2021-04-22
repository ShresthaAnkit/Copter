import 'package:copter/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copter',
      home: HomeScreen(),
    );
  }
}
