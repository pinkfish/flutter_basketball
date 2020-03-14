import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

import 'dialogplayerlist.dart';

///
/// Shows the players as a nice grid to be able to select from
/// and then where on the court the shot was from.
///
class GameShotDialog extends StatefulWidget {
  final Game game;
  final int points;

  GameShotDialog({@required this.game, this.points});

  @override
  State<StatefulWidget> createState() {
    return _GameShotDialogState();
  }
}

class _GameShotDialogState extends State<GameShotDialog> {
  int _currentTab = 0;
  String _selectedIncoming;

  bool _filterPlayer(String playerUid) {
    if (_currentTab == 1) {
      if (widget.game.opponents.containsKey(_selectedIncoming)) {
        return playerUid != _selectedIncoming &&
            widget.game.opponents.containsKey(playerUid);
      } else {
        return playerUid != _selectedIncoming &&
            widget.game.players.containsKey(playerUid);
      }
    }
    return true;
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    if (_currentTab == 0) {
      if (widget.points == 1) {
        Navigator.pop(context, Tuple2(playerUid, null));
      } else {
        setState(() {
          _currentTab = 1;
          _selectedIncoming = playerUid;
        });
      }
    }
  }

  void _tapUp(BoxConstraints box, TapUpDetails details) {
    double x;
    double y;
    if (box.maxWidth < box.maxHeight) {
      x = details.localPosition.dx / box.maxWidth;
      y = (details.localPosition.dy -
              (details.localPosition.dy - details.localPosition.dx) / 2) /
          box.maxWidth;
    } else {
      y = details.localPosition.dy / box.maxHeight;
      x = (details.localPosition.dx -
              (details.localPosition.dx - details.localPosition.dy) / 2) /
          box.maxHeight;
    }
    if (x < 0) {
      x = 0;
    }
    if (x > 1) {
      x = 1;
    }
    if (y < 0) {
      y = 0;
    }
    if (y > 1) {
      y = 1;
    }
    print("${details.localPosition} $x $y");
    Navigator.pop(
        context,
        Tuple2(
            _selectedIncoming,
            GameEventLocation((b) => b
              ..x = x
              ..y = y)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentTab == 0
          ? AppBar(
              title: Text("Select Player"),
              automaticallyImplyLeading: false,
            )
          : null,
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation o) {
          Widget cancelButton = FlatButton(
            child: Text(
              MaterialLocalizations.of(context).cancelButtonLabel,
              textScaleFactor: 1.5,
            ),
            onPressed: () => Navigator.pop(context, null),
          );
          return Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(
                    milliseconds: 500,
                  ),
                  child: _currentTab == 0
                      ? DialogPlayerList(
                          game: widget.game,
                          onSelectPlayer: _selectPlayer,
                          orientation: o,
                          filterPlayer: _filterPlayer,
                        )
                      : LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints box) {
                            print(box);
                            return GestureDetector(
                              onTapUp: (t) => _tapUp(box, t),
                              child: SvgPicture.asset(
                                  "assets/images/Basketball_Halfcourt.svg"),
                            );
                          },
                        ),
                ),
              ),
              ButtonBar(
                children: _currentTab == 0
                    ? [
                        cancelButton,
                      ]
                    : [
                        FlatButton(
                          child: Text(
                            MaterialLocalizations.of(context)
                                .continueButtonLabel,
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () => Navigator.pop(
                            context,
                            Tuple2(_selectedIncoming, null),
                          ),
                        ),
                        cancelButton,
                      ],
              ),
            ],
          );
        },
      ),
    );
  }
}
