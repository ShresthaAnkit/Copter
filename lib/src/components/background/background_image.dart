import 'package:flutter/material.dart';
import 'image_filter.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    Key key,
    @required String url,
  })  : _url = url,
        super(key: key);
  final String _url;

  @override
  Widget build(BuildContext context) {
    return ImageFilter(
      key: key,
      url: _url,
    );
  }
}
