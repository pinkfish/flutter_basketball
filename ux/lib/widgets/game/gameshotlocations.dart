import 'dart:math';

import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'gameplayerlist.dart';

///
/// Create a nifty diagram showing the locations of the shots.
///
class GameShotLocations extends StatefulWidget {
  final SingleGameState state;
  final Orientation orientation;

  GameShotLocations(
      {@required this.state, this.orientation = Orientation.portrait});

  @override
  State<StatefulWidget> createState() {
    return _GameShotLocationsState();
  }
}

class _GameShotLocationsState extends State<GameShotLocations> {
  String _selectedPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) => Row(
              children: [
                SizedBox(
                  width: min(box.maxHeight, 200),
                  child: SingleChildScrollView(
                    child: GamePlayerList(
                      game: widget.state.game,
                      sort: _sortFunc,
                      onSelectPlayer: _selectPlayer,
                      orientation: Orientation.portrait,
                      filterPlayer: (String playerUid) =>
                          _filterPlayer(playerUid),
                      compactDisplay: true,
                      selectedPlayer: _selectedPlayer,
                      extra: _extraDetails,
                    ),
                  ),
                ),
                Stack(
                  children: <Widget>[
                    SvgPicture.asset(
                      "assets/images/Basketball_Halfcourt.svg",
                    ),
                    SizedBox(
                      height: min(box.maxWidth, box.maxHeight),
                      width: min(box.maxWidth, box.maxHeight),
                      child: CustomPaint(
                        painter: _ImageBasketballStuff(
                          widget.state.gameEvents.where(
                            (GameEvent ev) {
                              if (_selectedPlayer != null &&
                                  ev.playerUid != _selectedPlayer) {
                                return false;
                              }
                              return _filterPlayer(ev.playerUid);
                            },
                          ),
                        ),
                      ),
                    ),
                    //_ImageBasketballStuff(widget.state.gameEvents),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _pointsByPlayer(String playerUid) {
    if (widget.state.game.opponents.containsKey(playerUid)) {
      return widget.state.game.opponents[playerUid].fullData.one.attempts +
          widget.state.game.opponents[playerUid].fullData.two.attempts +
          widget.state.game.opponents[playerUid].fullData.three.attempts;
    } else if (widget.state.game.players.containsKey(playerUid)) {
      return widget.state.game.players[playerUid].fullData.one.attempts +
          widget.state.game.players[playerUid].fullData.two.attempts +
          widget.state.game.players[playerUid].fullData.three.attempts;
    }
    return 0;
  }

  static int _sortFunc(Game game, String a, String b) {
    PlayerSummary asum = game.players[a] ?? game.opponents[a];
    PlayerSummary bsum = game.players[b] ?? game.opponents[b];
    return (bsum.fullData.one.attempts +
            bsum.fullData.two.attempts +
            bsum.fullData.three.attempts) -
        (asum.fullData.one.attempts +
            asum.fullData.two.attempts +
            asum.fullData.three.attempts);
  }

  bool _filterPlayer(String playerUid) {
    return _pointsByPlayer(playerUid) > 0;
  }

  Widget _extraDetails(String playerUid) {
    return Expanded(
      child: Text(
        _pointsByPlayer(playerUid).toString(),
        textAlign: TextAlign.end,
        style: Theme.of(context)
            .textTheme
            .subtitle
            .copyWith(color: Theme.of(context).accentColor),
      ),
    );
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    print("Selecting $playerUid");
    setState(() {
      if (_selectedPlayer == playerUid) {
        _selectedPlayer = null;
      } else {
        _selectedPlayer = playerUid;
      }
    });
  }
}

class _ImageBasketballStuff extends CustomPainter {
  final Iterable<GameEvent> events;

  _ImageBasketballStuff(this.events);

  final Paint madePainter = new Paint()
    ..color = Colors.blue[400]
    ..style = PaintingStyle.fill;
  final Paint missedPainter = new Paint()
    ..color = Colors.white
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  void _drawCross(Canvas canvas, Offset pos, Paint painter) {
    canvas.drawLine(Offset(pos.dx - 5, pos.dy + 5),
        Offset(pos.dx + 5, pos.dy - 5), painter);
    canvas.drawLine(Offset(pos.dx + 5, pos.dy + 5),
        Offset(pos.dx - 5, pos.dy - 5), painter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (GameEvent e in events) {
      if (e.courtLocation != null) {
        if (size.width < size.height) {
          canvas.drawCircle(
              Offset(
                (size.height - size.width) / 2 + size.width * e.courtLocation.x,
                size.width * e.courtLocation.y,
              ),
              10,
              e.type == GameEventType.Made ? madePainter : missedPainter);
        } else {
          Offset pos = Offset(
            size.height * e.courtLocation.x,
            (size.width - size.height) / 2 + size.height * e.courtLocation.y,
          );
          if (e.type == GameEventType.Made) {
            canvas.drawCircle(pos, 7, madePainter);
          } else {
            _drawCross(canvas, pos, missedPainter);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
