import 'package:flutter/material.dart';
import '../../size_config.dart';
import 'color_filter_generator.dart';
import 'image_filter.dart';

class ChangeBackground extends StatelessWidget {
  const ChangeBackground({
    Key key,
    @required bool imageState,
  })  : _imageState = imageState,
        super(key: key);

  final bool _imageState;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          _imageState ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 800),
      sizeCurve: Curves.ease,
      firstChild: ImageFilter(url: 'assets/images/background1.png'),
      secondChild: ImageFilter(url: 'assets/images/background2.jpg'),
    );
  }
}
