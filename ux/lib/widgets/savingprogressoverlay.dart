import 'dart:math';

import 'package:flutter/material.dart';

///
/// Shows an overlay over the main class when it is saving with some useful
/// information, does it as a semi-transparent overlay.
///
class SavingProgressOverlay extends StatefulWidget {
  final num percentage;

  SavingProgressOverlay(
      {@required bool saving, @required this.child, @required this.percentage})
      : _saving = saving ?? false;

  final bool _saving;
  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _CircleProgressState();
  }
}

class _CircleProgressState extends State<SavingProgressOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController progressController;
  Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = Tween(begin: 0, end: 80).animate(progressController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        widget.child,
        new AnimatedOpacity(
          opacity: widget._saving ? 0.8 : 0.0,
          duration: new Duration(seconds: 1),
          child: new Container(
            color: Colors.white,
            // Fill the whole page, drop it back when not saving to not
            // trap the gestures.
            constraints: widget._saving
                ? new BoxConstraints.expand()
                : new BoxConstraints.tight(const Size(0.0, 0.0)),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new SizedBox(height: 20.0),
                CustomPaint(
                  foregroundPainter: _CircleProgress(animation
                      .value), // this will add custom painter after child
                  child: Container(
                    width: 200,
                    height: 200,
                    child: GestureDetector(
                        onTap: () {
                          if (animation.value == 80) {
                            progressController.reverse();
                          } else {
                            progressController.forward();
                          }
                        },
                        child: Center(
                            child: Text(
                          "${animation.value.toInt()}%",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleProgress extends CustomPainter {
  double currentProgress;

  _CircleProgress(this.currentProgress);

  @override
  void paint(Canvas canvas, Size size) {
    //this is base circle
    Paint outerCircle = Paint()
      ..strokeWidth = 10
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = 10
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 10;

    canvas.drawCircle(
        center, radius, outerCircle); // this draws main outer circle

    double angle = 2 * pi * (currentProgress / 100);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
