import 'package:flutter/material.dart';

class Fireball extends StatelessWidget {
  const Fireball({
    Key key,
    @required double fireballYaxis,
    @required double fireballXaxis,
  })  : _fireballYaxis = fireballYaxis,
        _fireballXaxis = fireballXaxis,
        super(key: key);

  final double _fireballYaxis;
  final double _fireballXaxis;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 0),
      top: _fireballYaxis,
      left: _fireballXaxis,
      child: Image.asset("assets/images/fireball.png", scale: 5),
    );
  }
}
