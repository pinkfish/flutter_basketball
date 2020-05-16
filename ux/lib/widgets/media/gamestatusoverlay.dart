import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'gamestatus.dart';

///
/// Show the current state of the game in the overlay on top of the
/// video (or beside the video)
///
class GameStatusOverlay extends StatelessWidget {
  final GameStatus status;
  final bool initialized;

  GameStatusOverlay({@required this.status, this.initialized = true});

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Container();
    }
    var ptsTheme = Theme.of(context).textTheme.headline5;
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(status.ptsFor.toString(), style: ptsTheme),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text("-", style: ptsTheme),
            ),
            Text(status.ptsAgainst.toString(), style: ptsTheme),
          ],
        ),
      ),
    );
  }
}

///
/// Show the status for a specific video player overlay
///
class GameStatusVideoPlayerOverlay extends StatefulWidget {
  final SingleGameState state;
  final VideoPlayerController controller;

  GameStatusVideoPlayerOverlay({@required this.state, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _GameStatusVideoPlayerOverlayState();
  }
}

class _GameStatusVideoPlayerOverlayState
    extends State<GameStatusVideoPlayerOverlay> {
  VoidCallback listener;
  GameStatus status;

  @override
  void initState() {
    status = GameStatus(
        state: widget.state, position: widget.controller.value.position);
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (status.nextEvent < widget.controller.value.position) {
        setState(() {});
      }
    };
    widget.controller.addListener(listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return GameStatusOverlay(
      status: status,
      initialized: widget.controller.value.initialized,
    );
  }
}

///
/// Shows an overlay for the specific position in the data
///
class GameStatusPositionOverlay extends StatelessWidget {
  final SingleGameState state;
  final Duration position;

  GameStatusPositionOverlay({@required this.state, this.position});

  @override
  Widget build(BuildContext context) {
    var status = GameStatus(state: state, position: position);
    return GameStatusOverlay(
      status: status,
      initialized: true,
    );
  }
}
