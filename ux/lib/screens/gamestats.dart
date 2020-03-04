import 'dart:math';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/deleted.dart';
import 'package:basketballstats/widgets/gameeventwidget.dart';
import 'package:basketballstats/widgets/gameplayerdialog.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:basketballstats/widgets/roundbutton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:undo/undo.dart';

import '../messages.dart';

class GameStatsScreen extends StatelessWidget {
  final String gameUid;
  final String teamUid;
  final ChangeStack stack = new ChangeStack();

  GameStatsScreen(this.gameUid, this.teamUid);

  Future<void> _doAddPoints(BuildContext context, int pts, bool made) async {
    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Select the player.
    String playerUid = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return GamePlayerDialog(game: bloc.state.game);
        });
    if (playerUid == null) {
      return;
    }
    bloc.add(
      SingleGameAddEvent(
          event: GameEvent((b) => b
            ..playerUid = playerUid
            ..points = pts
            ..timestamp = (DateTime.now().toUtc())
            ..gameUid = gameUid
            ..period = bloc.state.game.currentPeriod
            ..opponent = bloc.state.game.opponents.containsKey(playerUid)
            ..type = made ? GameEventType.Made : GameEventType.Missed)),
    );
  }

  Future<void> _doBasicEvent(BuildContext context, GameEventType type) async {
    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Select the player.
    String playerUid = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return GamePlayerDialog(game: bloc.state.game);
        });
    if (playerUid == null) {
      return;
    }
    bloc.add(SingleGameAddEvent(
        event: GameEvent((b) => b
          ..playerUid = playerUid
          ..points = 0
          ..timestamp = DateTime.now().toUtc()
          ..type = type)));
  }

  Widget _buildPointSection(BuildContext context, BoxConstraints constraints) {
    double buttonSize = constraints.maxWidth / 4;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            RoundButton(
              child: Text("1"),
              size: buttonSize,
              borderColor: Colors.green,
              onPressed: () => _doAddPoints(context, 1, true),
            ),
            CustomPaint(
              painter: _LineThrough(),
              child: RoundButton(
                borderColor: Colors.red,
                size: buttonSize,
                onPressed: () => _doAddPoints(context, 1, false),
                child: Text(
                  "1",
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            RoundButton(
              borderColor: Colors.green,
              size: buttonSize,
              child: Text("2"),
              onPressed: () => _doAddPoints(context, 2, true),
            ),
            CustomPaint(
              painter: _LineThrough(),
              child: RoundButton(
                borderColor: Colors.red,
                size: buttonSize,
                child: Text(
                  "2",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () => _doAddPoints(context, 2, false),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            RoundButton(
              borderColor: Colors.green,
              size: buttonSize,
              child: Text("3"),
              onPressed: () => _doAddPoints(context, 3, true),
            ),
            CustomPaint(
              painter: _LineThrough(),
              child: RoundButton(
                borderColor: Colors.red,
                size: buttonSize,
                onPressed: () => _doAddPoints(context, 3, false),
                child: Text(
                  "3",
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            RoundButton(
              borderColor: Colors.blue,
              size: buttonSize * 3 / 4,
              child: Icon(Icons.undo),
              onPressed: stack.canUndo ? () => stack.undo() : null,
            ),
            RoundButton(
              borderColor: Colors.blue,
              size: buttonSize * 3 / 4,
              onPressed: stack.canRedo ? () => stack.redo() : null,
              child: Icon(
                Icons.redo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefenceSection(
      BuildContext context, BoxConstraints boxConstraints) {
    double buttonSize = boxConstraints.maxWidth / 4;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            RoundButton(
              borderColor: Colors.red,
              size: buttonSize,
              child: Text("OFF RB"),
              onPressed: () =>
                  _doBasicEvent(context, GameEventType.OffsensiveRebound),
            ),
            RoundButton(
              borderColor: Colors.red,
              size: buttonSize,
              child: Text(
                "DEF RB",
              ),
              onPressed: () =>
                  _doBasicEvent(context, GameEventType.DefensiveRebound),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            RoundButton(
              borderColor: Colors.red,
              size: buttonSize,
              child: Text("T/O"),
              onPressed: () => _doBasicEvent(context, GameEventType.Turnover),
            ),
            RoundButton(
              borderColor: Colors.red,
              size: buttonSize,
              child: Text(
                "STL",
              ),
              onPressed: () => _doBasicEvent(context, GameEventType.Steal),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            RoundButton(
              borderColor: Colors.red,
              size: buttonSize,
              child: Text("BLK"),
              onPressed: () => _doBasicEvent(context, GameEventType.Block),
            ),
            RoundButton(
              borderColor: Colors.red,
              size: buttonSize,
              child: Text(
                "ASST",
              ),
              onPressed: () => _doBasicEvent(context, GameEventType.Assist),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubButtons(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<SingleGameBloc>(context),
        builder: (BuildContext context, SingleGameState state) {
          if (state is SingleGameUninitialized) {
            return LoadingWidget();
          }
          if (state is SingleGameDeleted) {
            return DeletedWidget();
          }
          return ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(Messages.of(context).periodButton,
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(fontSize: 30.0)),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.blue),
                ),
                onPressed: () => _selectPeriod(context),
              ),
              FlatButton(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    Messages.of(context).subButton,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(fontSize: 30.0),
                  ),
                ),
                onPressed: () => _doBasicEvent(context, GameEventType.Sub),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
              FlatButton(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "FOUL",
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(fontSize: 30.0),
                  ),
                ),
                onPressed: () => _doBasicEvent(context, GameEventType.Foul),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(top: 20.0, right: 5.0, left: 5.0),
        child: BlocProvider(
          create: (BuildContext context) => SingleTeamBloc(
              teamUid: teamUid, db: BlocProvider.of<TeamsBloc>(context).db),
          child: BlocProvider(
            create: (BuildContext context) => SingleGameBloc(
                gameUid: gameUid, db: BlocProvider.of<TeamsBloc>(context).db),
            child: Column(
              children: <Widget>[
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints boxConstraint) =>
                          _buildPointSection(context, boxConstraint),
                ),
                Divider(),
                Expanded(
                  child: _GameStateSection(stack),
                ),
                Divider(),
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints boxConstraint) =>
                          _buildDefenceSection(context, boxConstraint),
                ),
                Builder(
                  builder: (BuildContext context) => _buildSubButtons(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectPeriod(BuildContext context) async {
    GamePeriod newPeriod = await showDialog<GamePeriod>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(Messages.of(context).period),
          children: GamePeriod.values
              .map((GamePeriod p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, p),
                  child: Text(Messages.of(context).getPeriodName(p))))
              .toList(),
        );
      },
    );
    if (newPeriod == null) {
      return;
    }

    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Write out the event to start the new period.
    bloc.add(
      SingleGameAddEvent(
          event: GameEvent((b) => b
            ..playerUid = ""
            ..points = 0
            ..timestamp = (DateTime.now().toUtc())
            ..gameUid = bloc.gameUid
            ..period = newPeriod
            ..opponent = false
            ..type = GameEventType.PeriodStart)),
    );
  }
}

class _GameStateSection extends StatelessWidget {
  final ChangeStack stack;

  _GameStateSection(this.stack);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<SingleGameBloc>(context),
      listener: (BuildContext context, SingleGameState state) {
        if (state is SingleGameLoaded && !state.loadedGameEvents) {
          BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadEvents());
        }
        if (state is SingleGameChangeEvents) {
          // Only worry about added events.
          for (GameEvent ev in state.newEvents) {
            stack.add(
                _GameEventChange(BlocProvider.of<SingleGameBloc>(context), ev));
          }
        }
      },
      builder: (BuildContext context, SingleGameState state) {
        if (state is SingleGameUninitialized) {
          return LoadingWidget();
        }
        if (state is SingleGameDeleted) {
          return DeletedWidget();
        }
        var style = Theme.of(context)
            .textTheme
            .headline
            .copyWith(fontWeight: FontWeight.bold);
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/basketball.png'),
              fit: BoxFit.fitHeight,
              alignment: Alignment.topCenter,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.2), BlendMode.dstATop),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Text(
                        Messages.of(context)
                            .getPeriodName(state.game.currentPeriod),
                        style: Theme.of(context).textTheme.body1),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BlocBuilder(
                              bloc: BlocProvider.of<SingleTeamBloc>(context),
                              builder: (BuildContext context,
                                  SingleTeamBlocState teamState) {
                                if (teamState is SingleTeamUninitialized ||
                                    teamState is SingleTeamDeleted) {
                                  return Text(Messages.of(context).loading,
                                      overflow: TextOverflow.fade,
                                      style: style);
                                }
                                return Text(teamState.team.name,
                                    overflow: TextOverflow.fade, style: style);
                              }),
                          Text(state.game.summary.pointsAgainst.toString(),
                              style: style),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(state.game.opponentName,
                              overflow: TextOverflow.fade, style: style),
                          Text(state.game.summary.pointsAgainst.toString(),
                              style: style),
                        ]),
                    ..._getGameEvents(context, state)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Iterable<Widget> _getGameEvents(BuildContext context, SingleGameState state) {
    if (state.gameEvents.isEmpty) {
      return [
        SizedBox(
          height: 0.0,
          width: 0,
        )
      ];
    }
    return state.gameEvents
        .sublist(max(state.gameEvents.length - 4, 0))
        .reversed
        .map(
          (GameEvent ev) => GameEventWidget(
            gameEvent: ev,
          ),
        );
  }
}

class _GameEventChange extends Change {
  final SingleGameBloc bloc;
  final GameEvent ev;
  bool ignored = false;

  _GameEventChange(this.bloc, this.ev);

  @override
  void execute() {
    if (!ignored) {
      ignored = true;
      return;
    }

    bloc.add(SingleGameAddEvent(event: ev));
  }

  @override
  void undo() {
    bloc.add(SingleGameRemoveEvent(eventUid: ev.uid));
  }
}

class _LineThrough extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    var start = const Alignment(-0.5, -0.0).alongSize(size);
    var end = const Alignment(0.5, 0.0).alongSize(size);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
