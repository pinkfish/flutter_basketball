import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';

///
/// Shows the game duration and keeps it updated while the clock is running
///
class GameDuration extends StatefulWidget {
  final TextStyle style;
  final double textScaleFactor;
  final SingleGameState state;

  GameDuration({this.style, this.textScaleFactor, this.state});

  @override
  State<StatefulWidget> createState() {
    return _GameDurationState();
  }
}

class _GameDurationState extends State<GameDuration> {
  Timer _timer;

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.game == null) {
      return SizedBox(
        height: 0,
      );
    }
    if (widget.state.game.runningFrom != null) {
      if (_timer == null) {
        _timer = Timer.periodic(Duration(seconds: 1), (t) => setState(() {}));
      }
    } else if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    int diff = 0;
    if (widget.state.game.runningFrom != null) {
      diff +=
          DateTime.now().difference(widget.state.game.runningFrom).inSeconds;
    }
    diff += widget.state.game.gameTime.inSeconds;

    return Text(
      twoDigits(diff ~/ 60) + ":" + twoDigits(diff % 60),
      style: widget.style,
      textScaleFactor: widget.textScaleFactor,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
