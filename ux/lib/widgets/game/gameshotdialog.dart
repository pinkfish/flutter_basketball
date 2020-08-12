import 'dart:math';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/localutilities.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../messages.dart';
import 'dialogplayerlist.dart';

///
/// The result of this dialog.
///
class GameShotResult {
  final String playerUid;
  final String assistPlayerUid;
  final GameEventLocation location;

  GameShotResult(this.playerUid, this.location, this.assistPlayerUid);
}

///
/// Shows the players as a nice grid to be able to select from
/// and then where on the court the shot was from.
///
class GameShotDialog extends StatefulWidget {
  final Game game;
  final int points;
  final bool made;

  GameShotDialog({@required this.game, this.points, this.made});

  @override
  State<StatefulWidget> createState() {
    return _GameShotDialogState();
  }
}

class _GameShotDialogState extends State<GameShotDialog> {
  int _currentTab = 0;
  String _selectedIncoming;
  String _selectedAssist;
  GameEventLocation _location;

  bool _filterPlayer(String playerUid) {
    return true;
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    if (_currentTab == 0) {
      if (widget.points == 1) {
        Navigator.pop(context, GameShotResult(playerUid, null, null));
      } else {
        setState(() {
          _currentTab++;
          _selectedIncoming = playerUid;
        });
      }
    }
  }

  bool _filterAssistPlayer(String playerUid) {
    // Only show opponents
    if (widget.game.opponents.containsKey(_selectedIncoming)) {
      return playerUid != _selectedIncoming &&
          widget.game.opponents.containsKey(playerUid);
    }
    // Only show players
    return playerUid != _selectedIncoming &&
        widget.game.players.containsKey(playerUid);
  }

  void _selectAssistPlayer(BuildContext context, String playerUid) {
    setState(() {
      _currentTab = 2;
      _selectedAssist = playerUid;
    });
    Navigator.pop(
        context,
        GameShotResult(
          _selectedIncoming,
          _location,
          _selectedAssist,
        ));
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
    setState(() {
      _currentTab++;
      _location = GameEventLocation((b) => b
        ..x = x
        ..y = y);
    });
  }

  void _onStepContinue() {
    if (_currentTab == 0) {
      // Verify the form first.
      if (_selectedIncoming == null) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(Messages.of(context).errorForm)));
        return;
      }
    }
    if (!widget.made) {
      Navigator.pop(context, GameShotResult(_selectedIncoming, null, null));
    }
    setState(() => _currentTab++);
  }

  Widget _stepperButtons(BuildContext context,
      {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: 48.0),
            child: ButtonBar(
              children: [
                _currentTab > 0
                    ? FlatButton(
                        onPressed: () {
                          setState(() => _currentTab++);
                        },
                        color: LocalUtilities.isDark(context)
                            ? themeData.backgroundColor
                            : themeData.primaryColor,
                        textColor: Colors.white,
                        textTheme: ButtonTextTheme.normal,
                        child: _location != null
                            ? Text(MaterialLocalizations.of(context)
                                .continueButtonLabel)
                            : Text(Messages.of(context).skipButton))
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: 48.0),
            child: ButtonBar(
              children: <Widget>[
                _currentTab == 1
                    ? FlatButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            GameShotResult(
                                _selectedIncoming, _location, _selectedAssist),
                          );
                        },
                        color: LocalUtilities.isDark(context)
                            ? themeData.backgroundColor
                            : themeData.primaryColor,
                        textColor: Colors.white,
                        textTheme: ButtonTextTheme.normal,
                        child: Text(Messages.of(context).doneButton))
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 8.0),
                  child: FlatButton(
                    onPressed: onStepCancel,
                    textColor: cancelColor,
                    textTheme: ButtonTextTheme.normal,
                    child: Text(localizations.cancelButtonLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentTab == 0
          ? AppBar(
              title: Text(Messages.of(context).selectPlayer),
              automaticallyImplyLeading: false,
            )
          : null,
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation o) {
          return Column(
            children: [
              Expanded(
                child: Stepper(
                  controlsBuilder: _stepperButtons,
                  currentStep: _currentTab,
                  onStepCancel: () => Navigator.pop(context, null),
                  onStepContinue: _onStepContinue,
                  onStepTapped: (int pos) => setState(() => _currentTab = pos),
                  steps: [
                    Step(
                      content: DialogPlayerList(
                        game: widget.game,
                        onSelectPlayer: _selectPlayer,
                        orientation: o,
                        filterPlayer: _filterPlayer,
                      ),
                      title: Text(Messages.of(context).players),
                      state: _currentTab == 0
                          ? StepState.editing
                          : StepState.complete,
                      subtitle: _currentTab > 0
                          ? PlayerName(
                              playerUid: _selectedIncoming,
                            )
                          : null,
                    ),
                    Step(
                      title: Text(Messages.of(context).location),
                      subtitle: _currentTab <= 1
                          ? Text(Messages.of(context).optional)
                          : _location == null
                              ? null
                              : Text(Messages.of(context).location),
                      state: widget.points == 1 || !widget.made
                          ? StepState.disabled
                          : _currentTab == 1
                              ? StepState.editing
                              : _currentTab > 1
                                  ? StepState.complete
                                  : StepState.indexed,
                      content: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints box) {
                          return GestureDetector(
                            onTapUp: (t) => _tapUp(box, t),
                            child: Stack(
                              children: <Widget>[
                                kIsWeb
                                    ? Image.network(
                                        "assets/images/Basketball_Halfcourt.svg",
                                        fit: BoxFit.contain,
                                        height:
                                            min(box.maxHeight, box.maxWidth),
                                        width: min(box.maxHeight, box.maxWidth),
                                      )
                                    : SvgPicture.asset(
                                        "assets/images/Basketball_Halfcourt.svg",
                                        height:
                                            min(box.maxHeight, box.maxWidth),
                                        width: min(box.maxHeight, box.maxWidth),
                                      ),
                                SizedBox(
                                  height: min(box.maxWidth, box.maxHeight),
                                  width: min(box.maxWidth, box.maxHeight),
                                  child: CustomPaint(
                                    painter: _ImageBasketballStuff(
                                      location: _location,
                                      fraction: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Step(
                      content: DialogPlayerList(
                        game: widget.game,
                        onSelectPlayer: _selectAssistPlayer,
                        orientation: o,
                        filterPlayer: _filterAssistPlayer,
                      ),
                      state: widget.points == 1 || !widget.made
                          ? StepState.disabled
                          : _currentTab == 2
                              ? StepState.editing
                              : _currentTab > 2
                                  ? StepState.complete
                                  : StepState.indexed,
                      title: Text(Messages.of(context).assistEvntType),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ImageBasketballStuff extends CustomPainter {
  final GameEventLocation location;
  final double fraction;

  _ImageBasketballStuff({this.location, this.fraction});

  final Paint madePainter = new Paint()
    ..color = Colors.blue[400]
    ..style = PaintingStyle.fill;

  void _drawEvent(Size size, Canvas canvas, double fraction) {
    if (location != null) {
      Offset pos;
      if (size.width < size.height) {
        pos = Offset(
          (size.height - size.width) / 2 + size.width * location.x,
          size.width * location.y,
        );
      } else {
        pos = Offset(
          size.height * location.x,
          (size.width - size.height) / 2 + size.height * location.y,
        );
      }
      canvas.drawCircle(pos, 7 * fraction, madePainter);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawEvent(size, canvas, fraction);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
