import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final double size;
  final Widget child;
  final Function onPressed;
  final Color borderColor;
  final double padding;
  final double innerPadding;
  final double maxHeight;

  RoundButton(
      {this.size = 20.0,
      this.child,
      this.onPressed,
      this.borderColor,
      this.padding = 5.0,
      this.innerPadding = 2.0,
      this.maxHeight = 40.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: FlatButton(
          child: SizedBox(
            width: size - padding - innerPadding,
            height: min(size - padding - innerPadding, maxHeight),
            child: FittedBox(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                return child;
              }),
            ),
          ),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((size - padding) / 2),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }
}
