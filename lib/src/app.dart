import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copter',
      home: GameScreen(),
    );
  }
}
