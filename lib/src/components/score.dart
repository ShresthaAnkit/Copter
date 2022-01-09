import 'package:flutter/material.dart';

class Score extends StatelessWidget {
  const Score({
    Key key,
    @required double scoreYaxis,
    @required double scoreXaxis,
    @required bool visible,
  })  : _scoreYaxis = scoreYaxis,
        _scoreXaxis = scoreXaxis,
        _visible = visible,
        super(key: key);

  final double _scoreYaxis;
  final double _scoreXaxis;
  final bool _visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 0),
      top: _scoreYaxis,
      left: _scoreXaxis,
      child: Opacity(
          opacity: (_visible) ? 1 : 0,
          child: Image.asset("assets/images/star.png", scale: 8)),
    );
  }
}
