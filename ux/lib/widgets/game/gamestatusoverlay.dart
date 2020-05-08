import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

///
/// Show the current state of the game in the overlay on top of the
/// video (or besie the video)
///
class GameStatusOverlay extends StatefulWidget {
  final SingleGameState state;
  final VideoPlayerController controller;

  GameStatusOverlay({this.state, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _GameStatusOverlayState();
  }
}

class _GameStatusOverlayState extends State<GameStatusOverlay> {
  VoidCallback listener;
  Duration nextEvent;
  int ptsFor = 0;
  int ptsAgainst = 0;
  int foulsFor = 0;
  int foulsAgainst = 0;
  GamePeriod period = GamePeriod.NotStarted;

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.initialized) {
      return Container();
    }
    Duration position = widget.controller.value.position;
    // Work out if we need to change stuff.
    if (position > nextEvent) {
      // Recalulate the score/fouls.
      for (var ev in widget.state.gameEvents) {
        if (ev.eventTimeline < position) {
          switch (ev.type) {
            case GameEventType.Made:
              if (ev.opponent) {
                ptsAgainst += ev.points;
              } else {
                ptsFor += ev.points;
              }
              break;
            case GameEventType.Missed:
              break;
            case GameEventType.Foul:
              if (ev.opponent) {
                foulsAgainst++;
              } else {
                foulsFor++;
              }
              break;
            case GameEventType.Sub:
              break;
            case GameEventType.OffsensiveRebound:
              break;
            case GameEventType.DefensiveRebound:
              break;
            case GameEventType.Block:
              break;
            case GameEventType.Assist:
              break;
            case GameEventType.Steal:
              break;
            case GameEventType.Turnover:
              break;
            case GameEventType.PeriodStart:
              period = ev.period;
              break;
          }
        }
      }
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
            Text(ptsFor.toString(), style: ptsTheme),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text("-", style: ptsTheme),
            ),
            Text(ptsAgainst.toString(), style: ptsTheme),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
    widget.controller.addListener(listener);
    nextEvent = widget.state.gameEvents.first.eventTimeline;
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(listener);
  }
}
