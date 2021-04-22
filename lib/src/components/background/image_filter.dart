import 'package:flutter/material.dart';
import 'color_filter_generator.dart';
import '../../size_config.dart';

class ImageFilter extends StatelessWidget {
  final String url;
  const ImageFilter({
    Key key,
    String url,
  })  : this.url = url,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
          ColorFilterGenerator.brightnessAdjustMatrix(value: -0.1)),
      child: Image.asset(
        '$url',
        fit: BoxFit.cover,
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
      ),
    );
  }
}
