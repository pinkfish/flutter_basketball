import 'package:flutter/material.dart';

///
/// Creates a popup floating action button
///
class PopupFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final List<Widget> children;

  PopupFab({this.onPressed, this.tooltip, this.icon, this.children});

  @override
  _PopupFabState createState() => _PopupFabState();
}

class _PopupFabState extends State<PopupFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 14.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight * (widget.children.length + 1),
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }
/*
  Widget add() {
    return FloatingActionButton(
        onPressed: null,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Inbox',
        child: Icon(Icons.inbox),
      ),
    );
  }

 */

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int pos = 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...widget.children.map((Widget w) => Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * pos++,
                0.0,
              ),
              child: Container(
                child: w,
              ),
            )),
        toggle(),
      ],
    );
  }
}
