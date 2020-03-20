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

class _GameShotLocationsState extends State<GameShotLocations>
    with SingleTickerProviderStateMixin {
  String _selectedPlayer;
  double _fraction = 0.0;
  Animation<double> _animation;
  Iterable<GameEvent> _oldEvents;
  Iterable<GameEvent> _events;
  AnimationController _controller;

  Iterable<GameEvent> _playerEvents(String playerUid) {
    return widget.state.gameEvents.where(
      (GameEvent ev) {
        if (ev.type != GameEventType.Made && ev.type != GameEventType.Missed) {
          return false;
        }
        if (playerUid != null && ev.playerUid != playerUid) {
          return false;
        }
        return _filterPlayer(ev.playerUid);
      },
    ).toList();
  }

  Widget _gamePlayerList(BuildContext context) {
    return SingleChildScrollView(
      child: GamePlayerList(
        game: widget.state.game,
        sort: _sortFunc,
        onSelectPlayer: _selectPlayer,
        orientation: Orientation.portrait,
        filterPlayer: (String playerUid) => _filterPlayer(playerUid),
        compactDisplay: true,
        selectedPlayer: _selectedPlayer,
        extra: _extraDetails,
      ),
    );
  }

  Widget _courtDetails(BuildContext context, BoxConstraints box) {
    return Stack(
      children: <Widget>[
        SvgPicture.asset(
          "assets/images/Basketball_Halfcourt.svg",
        ),
        SizedBox(
          height: min(box.maxWidth, box.maxHeight),
          width: min(box.maxWidth, box.maxHeight),
          child: CustomPaint(
            painter: _ImageBasketballStuff(
              events: _events,
              oldEvents: _oldEvents,
              fraction: _fraction,
            ),
          ),
        ),
        //_ImageBasketballStuff(widget.state.gameEvents),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) =>
                box.maxHeight < box.maxWidth
                    ? Row(
                        children: [
                          Expanded(
                            child: _gamePlayerList(context),
                          ),
                          _courtDetails(context, box),
                        ],
                      )
                    : Column(children: [
                        _courtDetails(context, box),
                        Expanded(child: _gamePlayerList(context)),
                      ]),
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
    PlayerGameSummary asum = game.players[a] ?? game.opponents[a];
    PlayerGameSummary bsum = game.players[b] ?? game.opponents[b];
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
    _controller.forward(from: 0.0);

    setState(() {
      String newPlayerUid;
      if (_selectedPlayer == playerUid) {
        newPlayerUid = null;
      } else {
        newPlayerUid = playerUid;
      }
      var newEvents = _playerEvents(newPlayerUid);

      _selectedPlayer = newPlayerUid;
      _oldEvents = _events.where((GameEvent ev) => !newEvents.contains(ev));
      _events = newEvents;
    });
  }

  void initState() {
    super.initState();
    _events = _playerEvents(_selectedPlayer);
    _oldEvents = [];
    _controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });

    _controller.forward();
  }
}

class _ImageBasketballStuff extends CustomPainter {
  final Iterable<GameEvent> events;
  final Iterable<GameEvent> oldEvents;
  final double fraction;

  _ImageBasketballStuff({this.events, this.oldEvents, this.fraction});

  final Paint madePainter = new Paint()
    ..color = Colors.blue[400]
    ..style = PaintingStyle.fill;
  final Paint missedPainter = new Paint()
    ..color = Colors.white
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  void _drawCross(Canvas canvas, Offset pos, Paint painter, double fraction) {
    double x = pos.dx;
    double y = pos.dy;
    double extra = 5 * fraction;
    canvas.drawLine(
        Offset(x - extra, y + extra), Offset(x + extra, y - extra), painter);
    canvas.drawLine(
        Offset(x + extra, y + extra), Offset(x - extra, y - extra), painter);
  }

  void _drawEvent(Size size, Canvas canvas, GameEvent e, double fraction) {
    if (e.courtLocation != null) {
      Offset pos;
      if (size.width < size.height) {
        pos = Offset(
          (size.height - size.width) / 2 + size.width * e.courtLocation.x,
          size.width * e.courtLocation.y,
        );
      } else {
        pos = Offset(
          size.height * e.courtLocation.x,
          (size.width - size.height) / 2 + size.height * e.courtLocation.y,
        );
      }
      if (e.type == GameEventType.Made) {
        canvas.drawCircle(pos, 7 * fraction, madePainter);
      } else {
        _drawCross(canvas, pos, missedPainter, fraction);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (GameEvent e in events) {
      _drawEvent(size, canvas, e, fraction);
    }
    for (GameEvent e in oldEvents) {
      _drawEvent(size, canvas, e, 1 - fraction);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
