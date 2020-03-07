import 'dart:math' as M;

import 'package:flutter/material.dart';

enum MenuLocation {
  BottomRight, //The lower right corner
  BottomLeft //The lower left corner
}

/// FabMenu
// ignore: must_be_immutable
class FabMenu extends StatefulWidget {
  // center fab must be init
  final List<FloatingActionButton> children;
  final MenuLocation location;
  final String tooltip;
  final bool mini;
  final int closeColor;
  final IconData icon;

  FabMenu(
      {this.mini = false,
      this.icon,
      this.closeColor = 0xffff0000,
      this.tooltip,
      this.children,
      this.location});

  @override
  _FabMenuState createState() {
    return _FabMenuState(fabItems: children, location: location);
  }
}

class _FabMenuState extends State<FabMenu> with TickerProviderStateMixin {
  static const String menuBtn = 'menuBtn';
  static const String actionBtn = 'actionBtn';
  AnimationController _animationController;
  List<LayoutId> _fabItems = [];
  MenuLocation location;
  bool isOpen = false;

  _FabMenuState(
      {@required List<FloatingActionButton> fabItems,
      this.location,
      String tooltip,
      bool mini,
      int closeColor,
      IconData icon}) {
    // init _fabItems
    for (int i = 0; i < fabItems.length; i++) {
      _fabItems.add(LayoutId(id: '$actionBtn$i', child: fabItems[i]));
    }
    _fabItems.add(
      LayoutId(
        id: "$menuBtn",
        child: CenterFab(
          icon: icon,
          tooltip: tooltip,
          mini: mini,
          closeColor: closeColor,
          menuCallback: () {
            this._changeMenu();
          },
        ),
      ),
    );
  }

  /// center fab callback
  void _changeMenu() {
    if (!isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpen = !isOpen;
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        return CustomMultiChildLayout(
          delegate: _FabMenuDelegate(
              controller: _animationController.view,
              menuLocation:
                  location == null ? MenuLocation.BottomRight : location,
              count: _fabItems.length),
          children: _fabItems,
        );
      },
    );
  }
}

class _FabMenuDelegate extends MultiChildLayoutDelegate {
  static const double margin = 16.0;
  final Animation<double> _animation;
  final Animation<double> controller;
  MenuLocation menuLocation;
  final int count;

  _FabMenuDelegate({@required this.controller, this.menuLocation, this.count})
      : _animation = Tween<double>(begin: 0.0, end: 100).animate(
            CurvedAnimation(curve: Curves.elasticOut, parent: controller));

  Offset _calcMenuLocation(Size size, Size widget) {
    switch (this.menuLocation) {
      case MenuLocation.BottomLeft:
        double h = size.height - widget.height - margin;
        return Offset(margin, h);
      case MenuLocation.BottomRight:
      default:
        double w = size.width - widget.width - margin;
        double h = size.height - widget.height - margin;
        return Offset(w, h);
    }
  }

  Offset _calcItemLocation(int index, Size size, Size widget) {
    Offset location = _calcMenuLocation(size, widget);
    switch (this.menuLocation) {
      case MenuLocation.BottomLeft:
        double radians = -index * 45 * (M.pi / 180);
        double cos = _animation.value * M.cos(radians);
        double sin = _animation.value * M.sin(radians);
        return Offset(location.dx + cos, location.dy + sin);
      case MenuLocation.BottomRight:
      default:
        double radians = ((index * 45) - 180) * (M.pi / 180);
        double cos = _animation.value * M.cos(radians);
        double sin = _animation.value * M.sin(radians);
        return Offset(location.dx + cos, location.dy + sin);
    }
  }

  Size centerSize;

  @override
  void performLayout(Size size) {
    if (hasChild(_FabMenuState.menuBtn)) {
      centerSize =
          layoutChild(_FabMenuState.menuBtn, BoxConstraints.loose(size));
      positionChild(_FabMenuState.menuBtn, _calcMenuLocation(size, centerSize));
    }
    for (int i = 0; i < count; i++) {
      String btn = '${_FabMenuState.actionBtn}$i';
      if (hasChild(btn)) {
        var itemSize = layoutChild(btn, BoxConstraints.loose(size));
        positionChild(btn, _calcItemLocation(i, size, itemSize));
      }
    }
  }

  @override
  bool shouldRelayout(_FabMenuDelegate oldDelegate) => true;
}

/// [CenterFab] is wrapper AnimatedCrossFade StatefulWidget
/// [_CenterFabState] fades between two representations of the FloatingActionButton.
/// It depends on a boolean field _isOpen; when _isOpen is true, the first fab [close] is show,
/// otherwise the second fab[centerMenu] is shown.
/// When the field changes state, the AnimatedCrossFade widget cross-fades between the two forms of the fab over 300 milliseconds.
class CenterFab extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool mini;
  final int closeColor;
  final VoidCallback menuCallback;

  CenterFab(
      {@required this.icon,
      this.tooltip,
      this.mini = false,
      this.closeColor = 0xffff0000,
      this.menuCallback});

  @override
  _CenterFabState createState() => _CenterFabState(
      icon: this.icon,
      tooltip: this.tooltip,
      mini: this.mini,
      closeColor: this.closeColor,
      menuCallback: this.menuCallback);
}

class _CenterFabState extends State<CenterFab> {
  bool _isOpen = false;
  VoidCallback menuCallback;

  _CenterFabState(
      {@required IconData icon,
      String tooltip,
      bool mini = false,
      int closeColor = 0xffff0000,
      this.menuCallback});

  changeState() {
    menuCallback();
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        // Close Menu
        firstChild: FloatingActionButton(
            heroTag: "toggleButton",
            onPressed: changeState,
            child: Icon(Icons.close),
            backgroundColor: Color(0xffff0000),
            mini: false),
        // Center Menu
        secondChild: FloatingActionButton(
            onPressed: changeState, child: Icon(Icons.menu), mini: false),
        crossFadeState:
            _isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      ),
    );
  }
}
