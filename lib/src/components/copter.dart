import 'package:flutter/material.dart';
import '../size_config.dart';

class Copter extends StatelessWidget {
  const Copter({
    Key key,
    @required double heliYaxis,
  })  : _heliYaxis = heliYaxis,
        super(key: key);

  final double _heliYaxis;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: _heliYaxis,
      left: (SizeConfig.screenWidth) / 2.2,
      duration: Duration(milliseconds: 0),
      child: Image.asset('assets/images/helicopter.png', scale: 5),
    );
  }
}
