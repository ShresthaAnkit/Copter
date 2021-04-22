import 'package:flutter/material.dart';
import '../size_config.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  Widget build(context) {
    SizeConfig().init(context);
    return GameScreen();
  }
}
