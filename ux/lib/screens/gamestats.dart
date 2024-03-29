import 'dart:async';
import 'dart:math';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/deleted.dart';
import 'package:basketballstats/widgets/game/gameduration.dart';
import 'package:basketballstats/widgets/game/gameeventwidget.dart';
import 'package:basketballstats/widgets/game/gameplayerdialog.dart';
import 'package:basketballstats/widgets/game/gameshotdialog.dart';
import 'package:basketballstats/widgets/game/gamesubsitutedialog.dart';
import 'package:basketballstats/widgets/game/startperiod.dart';
import 'package:basketballstats/widgets/game/timeoutstop.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:basketballstats/widgets/util/roundbutton.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';

typedef SelectCallback = void Function(BuildContext context);

///
/// Shows nifty stuff about stats and the game.  This lets the game update
/// the current status, points ewtc.
///
class GameStatsScreen extends StatelessWidget {
  final String gameUid;
  final String seasonUid;
  final String teamUid;

  GameStatsScreen(this.gameUid, this.seasonUid, this.teamUid);

  Future<void> _doAddPoints(BuildContext context, int pts, bool made) async {
    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Select the player.
    var playerData = await showDialog<GameShotResult>(
        context: context,
        builder: (BuildContext context) {
          return GameShotDialog(game: bloc.state.game, points: pts, made: made);
        });
    if (playerData == null) {
      return;
    }
    var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
    undoBloc.addEvent(
      GameEvent((b) => b
        ..playerUid = playerData.playerUid
        ..points = pts
        ..timestamp = (DateTime.now().toUtc())
        ..gameUid = gameUid
        ..period = bloc.state.game.currentPeriod
        ..eventTimeline = bloc.state.game.currentGameTime
        ..opponent = bloc.state.game.opponents.containsKey(playerData.playerUid)
        ..courtLocation = (playerData.location != null
            ? playerData.location.toBuilder()
            : null)
        ..type = made ? GameEventType.Made : GameEventType.Missed),
      false,
    );
    if (playerData.assistPlayerUid != null) {
      undoBloc.addEvent(
        GameEvent(
          (b) => b
            ..playerUid = playerData.assistPlayerUid
            ..points = pts
            ..timestamp = (DateTime.now().toUtc())
            ..gameUid = gameUid
            ..period = bloc.state.game.currentPeriod
            ..eventTimeline = bloc.state.game.currentGameTime
            ..opponent =
                bloc.state.game.opponents.containsKey(playerData.playerUid)
            ..type = GameEventType.Made,
        ),
        false,
      );
    }
  }

  Future<void> _doSubEvent(BuildContext context, GameEventType type) async {
    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Select the player.
    var playerData = await showDialog<Tuple2<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return GamePlayerSubsitutionDialog(game: bloc.state.game);
        });
    if (playerData == null) {
      return;
    }
    var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
    undoBloc.addEvent(
      GameEvent((b) => b
        ..playerUid = playerData.item1
        ..replacementPlayerUid = playerData.item2
        ..points = 0
        ..gameUid = gameUid
        ..period = bloc.state.game.currentPeriod
        ..opponent = bloc.state.game.opponents.containsKey(playerData.item1)
        ..eventTimeline = bloc.state.game.currentGameTime
        ..timestamp = DateTime.now().toUtc()
        ..type = type),
      false,
    );
    // Update the game to add in the subs.
    MapBuilder<String, PlayerSummaryWithOpponent> data = MapBuilder();
    if (bloc.state.game.players.containsKey(playerData.item1)) {
      var summary = bloc.state.game.players[playerData.item1]
          .rebuild((b) => b..currentlyPlaying = true);
      data[playerData.item1] = PlayerSummaryWithOpponent(false, summary);

      if (playerData.item2 != null) {
        var summary = bloc.state.game.players[playerData.item2]
            .rebuild((b) => b..currentlyPlaying = false);
        data[playerData.item2] = PlayerSummaryWithOpponent(false, summary);
      }
    }
    if (bloc.state.game.opponents.containsKey(playerData.item1)) {
      var summary = bloc.state.game.opponents[playerData.item1]
          .rebuild((b) => b..currentlyPlaying = true);
      data[playerData.item1] = PlayerSummaryWithOpponent(true, summary);

      if (playerData.item2 != null) {
        var summary = bloc.state.game.opponents[playerData.item2]
            .rebuild((b) => b..currentlyPlaying = false);
        data[playerData.item2] = PlayerSummaryWithOpponent(true, summary);
      }
    }
    bloc.add(SingleGameUpdatePlayer(summary: data.build()));
  }

  Future<void> _doBasicEvent(BuildContext context, GameEventType type) async {
    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Select the player.
    GamePlayerExtraButtons extra;
    GameFoulType foulType;
    StreamController<bool> updateDialogStream = StreamController<bool>();
    if (type == GameEventType.Foul) {
      foulType = GameFoulType.Personal;
      extra = (c) => [
            DropdownButton<GameFoulType>(
              value: foulType,
              onChanged: (GameFoulType t) {
                foulType = t;
                updateDialogStream.add(true);
              },
              items: GameFoulType.values
                  .map(
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(Messages.of(context).foultype(i)),
                    ),
                  )
                  .toList(),
            ),
          ];
    }
    String playerUid = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return GamePlayerDialog(
            changeStream: updateDialogStream.stream,
            game: bloc.state.game,
            extraButtons: extra,
          );
        });
    updateDialogStream.close();
    if (playerUid == null) {
      return;
    }
    var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
    undoBloc.addEvent(
      GameEvent((b) => b
        ..playerUid = playerUid
        ..points = 0
        ..gameUid = gameUid
        ..period = bloc.state.game.currentPeriod
        ..opponent = bloc.state.game.opponents.containsKey(playerUid)
        ..eventTimeline = bloc.state.game.currentGameTime
        ..timestamp = DateTime.now().toUtc()
        ..foulType = foulType
        ..type = type),
      false,
    );
  }

  Widget _buildPointSection(BuildContext context, BoxConstraints constraints,
      Orientation orientation) {
    double buttonSize;
    if (orientation == Orientation.portrait) {
      buttonSize = constraints.maxWidth / 4;
    } else {
      buttonSize = constraints.maxHeight / 4;
    }
    List<Widget> firstWidgets = <Widget>[
      Hero(
        tag: "1plus",
        child: RoundButton(
          child: Text("1"),
          size: buttonSize,
          borderColor: Colors.green,
          onPressed: () => _doAddPoints(context, 1, true),
        ),
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
    ];
    List<Widget> secondidgets = <Widget>[
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
    ];
    List<Widget> thirdWidgets = <Widget>[
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
    ];
    var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
    List<Widget> fourWidgets = <Widget>[
      RoundButton(
        borderColor: Colors.blue,
        size: buttonSize * 3 / 4,
        child: Icon(Icons.undo),
        onPressed: undoBloc.canUndo ? () => undoBloc.undo() : null,
      ),
      RoundButton(
        borderColor: Colors.blue,
        size: buttonSize * 3 / 4,
        onPressed: undoBloc.canRedo ? () => undoBloc.redo() : null,
        child: Icon(
          Icons.redo,
        ),
      ),
    ];
    if (orientation == Orientation.portrait) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: firstWidgets,
          ),
          Column(
            children: secondidgets,
          ),
          Column(
            children: thirdWidgets,
          ),
          Column(
            children: fourWidgets,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: firstWidgets,
          ),
          Row(
            children: secondidgets,
          ),
          Row(
            children: thirdWidgets,
          ),
          Row(
            children: fourWidgets,
          ),
        ],
      );
    }
  }

  Widget _buildDefenceSection(BuildContext context,
      BoxConstraints boxConstraints, Orientation orientation) {
    double buttonSize;
    if (orientation == Orientation.portrait) {
      buttonSize = boxConstraints.maxWidth / 4;
    } else {
      buttonSize = boxConstraints.maxHeight / 4;
    }
    List<Widget> firstWidgets = <Widget>[
      RoundButton(
        borderColor: Colors.red,
        size: buttonSize,
        child: Text(Messages.of(context).offensiveReboundButton),
        onPressed: () =>
            _doBasicEvent(context, GameEventType.OffsensiveRebound),
      ),
      RoundButton(
        borderColor: Colors.red,
        size: buttonSize,
        child: Text(
          Messages.of(context).defensiveReboundButton,
        ),
        onPressed: () => _doBasicEvent(context, GameEventType.DefensiveRebound),
      ),
    ];
    List<Widget> secondWidgets = <Widget>[
      RoundButton(
        borderColor: Colors.red,
        size: buttonSize,
        child: Text(Messages.of(context).turnoverButton),
        onPressed: () => _doBasicEvent(context, GameEventType.Turnover),
      ),
      RoundButton(
        borderColor: Colors.red,
        size: buttonSize,
        child: Text(
          Messages.of(context).stealButton,
        ),
        onPressed: () => _doBasicEvent(context, GameEventType.Steal),
      ),
    ];
    List<Widget> thirdWidgets = <Widget>[
      RoundButton(
        borderColor: Colors.red,
        size: buttonSize,
        child: Text(Messages.of(context).blockButton),
        onPressed: () => _doBasicEvent(context, GameEventType.Block),
      ),
/*      RoundButton(
        borderColor: Colors.red,
        size: buttonSize,
        child: Text(
          Messages.of(context).assistButton,
        ),
        onPressed: () => _doBasicEvent(context, GameEventType.Assist),
      ), */
    ];

    if (orientation == Orientation.portrait) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: firstWidgets,
          ),
          Column(
            children: secondWidgets,
          ),
          Column(
            children: thirdWidgets,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: firstWidgets,
          ),
          Row(
            children: secondWidgets,
          ),
          Row(
            children: thirdWidgets,
          ),
          _buildSubButtons(context, orientation, boxConstraints),
        ],
      );
    }
  }

  Widget _buildSubButtons(BuildContext context, Orientation orientation,
      BoxConstraints boxConstraints) {
    print(boxConstraints);
    return BlocBuilder(
        cubit: BlocProvider.of<SingleGameBloc>(context),
        builder: (BuildContext context, SingleGameState state) {
          if (state is SingleGameUninitialized) {
            return LoadingWidget();
          }
          if (state is SingleGameDeleted) {
            return DeletedWidget();
          }
          double padding = 10.0;
          if (boxConstraints.maxWidth < 336 &&
              orientation == Orientation.portrait) {
            padding = 10 - (336 - boxConstraints.maxWidth) / 3;
          }
          var buttons = <Widget>[
            FlatButton(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: padding, right: padding),
                child: Text(
                  Messages.of(context).subButton,
                  style: Theme.of(context).textTheme.button,
                  textScaleFactor: 1.5,
                ),
              ),
              onPressed: () => _doSubEvent(context, GameEventType.Sub),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.blue),
              ),
            ),
            FlatButton(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: padding, right: padding),
                child: Text(
                  Messages.of(context).foulButton,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              onPressed: () => _doBasicEvent(context, GameEventType.Foul),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.blue),
              ),
            ),
          ];
          if (orientation == Orientation.portrait) {
            buttons.insert(
              0,
              FlatButton(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: padding, right: padding),
                  child: Text(
                    Messages.of(context).periodButton,
                    style: Theme.of(context).textTheme.button,
                    textScaleFactor: 1.5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.blue),
                ),
                onPressed: () => _selectPeriod(context),
              ),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: buttons,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(top: 20.0, right: 5.0, left: 5.0),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (BuildContext context) => SingleTeamBloc(
                  teamUid: teamUid,
                  db: BlocProvider.of<TeamsBloc>(context).db,
                  crashes: RepositoryProvider.of<CrashReporting>(context)),
            ),
            BlocProvider(
                create: (BuildContext context) => SingleGameBloc(
                      gameUid: gameUid,
                      db: BlocProvider.of<TeamsBloc>(context).db,
                      crashes: RepositoryProvider.of<CrashReporting>(context),
                      loadGameEvents: true,
                    )),
            BlocProvider(
              create: (BuildContext context) => SingleSeasonBloc(
                  seasonUid: seasonUid,
                  db: BlocProvider.of<TeamsBloc>(context).db,
                  crashes: RepositoryProvider.of<CrashReporting>(context)),
            ),
            BlocProvider<GameEventUndoStack>(
              create: (BuildContext context) => GameEventUndoStack(
                db: RepositoryProvider.of<BasketballDatabase>(context),
              ),
            ),
            BlocProvider<AddPlayerBloc>(
              create: (BuildContext context) => AddPlayerBloc(
                  db: BlocProvider.of<TeamsBloc>(context).db,
                  crashes: RepositoryProvider.of<CrashReporting>(context)),
            ),
          ],
          child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) =>
                BlocListener(
              cubit: BlocProvider.of<AddPlayerBloc>(context),
              listener: (BuildContext context, AddItemState state) {
                // Once we make the player, save it to the game.
                if (state is AddItemDone) {
                  print("Saved player ${state.uid}");
                  BlocProvider.of<SingleGameBloc>(context)
                      .add(SingleGameAddPlayer(
                    playerUid: state.uid,
                    opponent: true,
                  ));
                }
              },
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: BlocBuilder(
                  cubit: BlocProvider.of<SingleGameBloc>(context),
                  builder: (BuildContext context, SingleGameState state) {
                    // Preload the undo set if it is not yet loaded.
                    if (state is SingleGameLoaded && state.loadedGameEvents) {
                      var undoBloc =
                          BlocProvider.of<GameEventUndoStack>(context);
                      print("undoBloc $undoBloc");
                      if (undoBloc.isGameEmpty) {
                        // Fill in with all these stats.
                        for (GameEvent ev in state.gameEvents) {
                          undoBloc.addEvent(ev, true);
                        }
                      }
                    }

                    if (state is SingleGameUninitialized ||
                        (state is SingleGameLoaded &&
                            !state.loadedGameEvents)) {
                      return LoadingWidget(
                        showAppBar: true,
                        game: state.game,
                      );
                    }

                    if (state is SingleGameLoaded &&
                        state.game.opponents.isEmpty) {
                      // ignore: close_sinks
                      var addPlayerBloc =
                          BlocProvider.of<AddPlayerBloc>(context);
                      if (addPlayerBloc.state is AddItemUninitialized) {
                        print("Adding missing opponent");
                        addPlayerBloc.add(
                          AddPlayerEventCommit(
                              newPlayer: Player((b) => b
                                ..name = state.game.opponentName.isNotEmpty
                                    ? state.game.opponentName
                                    : "default"
                                ..jerseyNumber = "xx")),
                        );
                      }
                    }
                    if ((state.loadedGameEvents &&
                            (state.gameEvents.length == 0 ||
                                state.gameEvents.last.type ==
                                    GameEventType.PeriodEnd)) ||
                        state.game?.currentPeriod == GamePeriod.NotStarted) {
                      return BlocBuilder(
                        cubit: BlocProvider.of<SingleSeasonBloc>(context),
                        builder: (BuildContext context,
                            SingleSeasonState seasonState) {
                          if (seasonState is SingleSeasonUninitialized) {
                            return LoadingWidget();
                          }
                          return StartPeriod(
                            game: state.game,
                            season: seasonState.season,
                            orientation: orientation,
                          );
                        },
                      );
                    }
                    if (state.loadedGameEvents &&
                        (state.gameEvents.length == 0 ||
                            state.gameEvents.last.type ==
                                GameEventType.TimeoutStart)) {
                      return TimeoutEnd(game: state.game);
                    }
                    if (orientation == Orientation.landscape) {
                      var undoBloc =
                          BlocProvider.of<GameEventUndoStack>(context);
                      return Row(
                        children: <Widget>[
                          LayoutBuilder(
                            builder: (BuildContext context,
                                    BoxConstraints boxConstraint) =>
                                _buildPointSection(
                                    context, boxConstraint, orientation),
                          ),
                          Expanded(
                            child: _GameStateSection(
                                undoBloc, orientation, _selectPeriod),
                          ),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                    BoxConstraints boxConstraint) =>
                                _buildDefenceSection(
                                    context, boxConstraint, orientation),
                          ),
                        ],
                      );
                    } else {
                      var undoBloc =
                          BlocProvider.of<GameEventUndoStack>(context);
                      return Column(
                        children: <Widget>[
                          LayoutBuilder(
                            builder: (BuildContext context,
                                    BoxConstraints boxConstraint) =>
                                _buildPointSection(
                                    context, boxConstraint, orientation),
                          ),
                          Divider(),
                          Expanded(
                            child: _GameStateSection(
                                undoBloc, orientation, _selectPeriod),
                          ),
                          Divider(),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                    BoxConstraints boxConstraint) =>
                                _buildDefenceSection(
                                    context, boxConstraint, orientation),
                          ),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                    BoxConstraints boxConstraint) =>
                                _buildSubButtons(
                                    context, orientation, boxConstraint),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectPeriod(BuildContext context) async {
    // ignore: close_sinks
    var bloc = BlocProvider.of<SingleGameBloc>(context);

    // Write out the event to start the new period.
    var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
    undoBloc.addEvent(
      GameEvent((b) => b
        ..playerUid = ""
        ..points = 0
        ..timestamp = (DateTime.now().toUtc())
        ..gameUid = bloc.gameUid
        ..period = bloc.state.game.currentPeriod
        ..opponent = false
        ..type = GameEventType.PeriodEnd),
      false,
    );

    // Update the game to stop the clock.
    if (bloc.state.game.runningFrom != null) {
      int newSeconds = bloc.state.game.gameTime.inSeconds +
          DateTime.now().difference(bloc.state.game.runningFrom).inSeconds;
      bloc.add(
        SingleGameUpdate(
          game: bloc.state.game.rebuild((b) => b
            ..gameTime = Duration(seconds: newSeconds)
            ..runningFrom = null),
        ),
      );
    }
  }
}

class _GameStateSection extends StatelessWidget {
  final GameEventUndoStack undoCubit;
  final Orientation orientation;
  final SelectCallback selectCallback;

  _GameStateSection(this.undoCubit, this.orientation, this.selectCallback);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<SingleGameBloc>(context),
      builder: (BuildContext context, SingleGameState state) {
        if (state is SingleGameUninitialized) {
          return LoadingWidget();
        }
        if (state is SingleGameDeleted) {
          return DeletedWidget();
        }
        var style = Theme.of(context)
            .textTheme
            .headline5
            .copyWith(fontWeight: FontWeight.bold);
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/basketball.png'),
              fit: orientation == Orientation.portrait
                  ? BoxFit.fitHeight
                  : BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.2), BlendMode.dstATop),
            ),
          ),
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    orientation == Orientation.portrait
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Messages.of(context)
                                    .getPeriodName(state.game.currentPeriod),
                                style: Theme.of(context).textTheme.bodyText2,
                                textScaleFactor: 1.5,
                              ),
                              IconButton(
                                icon: state.game.runningFrom != null
                                    ? Icon(
                                        Icons.pause,
                                        size: 40.0,
                                      )
                                    : Icon(
                                        Icons.play_arrow,
                                        size: 40.0,
                                      ),
                                onPressed: () =>
                                    _updateRunning(context, state.game),
                              ),
                              GameDuration(
                                state: state,
                                style: Theme.of(context).textTheme.bodyText2,
                                textScaleFactor: 1.5,
                              ),
                            ],
                          )
                        : ButtonBar(
                            alignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlatButton(
                                color: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme
                                    .background,
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    Messages.of(context).periodButton,
                                    style: Theme.of(context).textTheme.button,
                                    textScaleFactor: 1.5,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: BorderSide(color: Colors.blue),
                                ),
                                onPressed: () => selectCallback(context),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 40.0,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder(
                                  cubit:
                                      BlocProvider.of<SingleTeamBloc>(context),
                                  builder: (BuildContext context,
                                      SingleTeamState teamState) {
                                    if (teamState is SingleTeamUninitialized ||
                                        teamState is SingleTeamDeleted) {
                                      return Text(
                                          Messages.of(context).loadingText,
                                          overflow: TextOverflow.fade,
                                          style: style);
                                    }
                                    return Text(teamState.team.name,
                                        overflow: TextOverflow.fade,
                                        style: style);
                                  }),
                              Text(state.game.opponentName,
                                  overflow: TextOverflow.fade, style: style),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(state.game.summary.pointsAgainst.toString(),
                                style: style),
                            Text(state.game.summary.pointsAgainst.toString(),
                                style: style),
                          ],
                        ),
                        orientation == Orientation.portrait
                            ? IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 40.0,
                                ),
                                onPressed: () => Navigator.pop(context),
                              )
                            : SizedBox(width: 0.0),
                      ],
                    ),
                    orientation == Orientation.landscape
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Messages.of(context)
                                    .getPeriodName(state.game.currentPeriod),
                                style: Theme.of(context).textTheme.bodyText2,
                                textScaleFactor: 1.5,
                              ),
                              IconButton(
                                icon: state.game.runningFrom != null
                                    ? Icon(
                                        Icons.pause,
                                        size: 40.0,
                                      )
                                    : Icon(
                                        Icons.play_arrow,
                                        size: 40.0,
                                      ),
                                onPressed: () =>
                                    _updateRunning(context, state.game),
                              ),
                              GameDuration(
                                state: state,
                                style: Theme.of(context).textTheme.bodyText2,
                                textScaleFactor: 1.5,
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 0.0,
                          ),
                    Divider(),
                    Expanded(
                      child: AnimatedList(
                        initialItemCount: min(state.gameEvents.length, 4),
                        itemBuilder: (BuildContext context, int itexmIndex,
                            Animation<double> a) {
                          var item = state.gameEvents[
                              state.gameEvents.length - 1 - itexmIndex];
                          return GameEventWidget(gameEvent: item);
                        },
                      ),
                    ),
                    //..._getGameEvents(context, state)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateRunning(BuildContext context, Game g) {
    if (g.runningFrom != null) {
      int newSeconds = g.gameTime.inSeconds +
          DateTime.now().difference(g.runningFrom).inSeconds;
      Game newGame = g.rebuild((b) => b
        ..gameTime = Duration(seconds: newSeconds)
        ..runningFrom = null);
      BlocProvider.of<SingleGameBloc>(context)
          .add(SingleGameUpdate(game: newGame));
    } else {
      Game newGame = g.rebuild((b) => b..runningFrom = DateTime.now().toUtc());
      BlocProvider.of<SingleGameBloc>(context)
          .add(SingleGameUpdate(game: newGame));
    }
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
