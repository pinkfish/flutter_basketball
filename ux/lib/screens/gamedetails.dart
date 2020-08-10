import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/localstoragedata.dart';
import 'package:basketballstats/widgets/game/gameduration.dart';
import 'package:basketballstats/widgets/game/playerdatatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/game/gameshotlocations.dart';
import '../widgets/game/gametimeseries.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';
import 'gameplayeradd.dart';

///
/// Shows details of the game.
///
class GameDetailsScreen extends StatelessWidget {
  final String gameUid;

  GameDetailsScreen(this.gameUid);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SingleGameBloc>(
          create: (BuildContext context) => SingleGameBloc(
            gameUid: gameUid,
            db: BlocProvider.of<TeamsBloc>(context).db,
            crashes: RepositoryProvider.of<CrashReporting>(context),
            loadGameEvents: true,
            loadPlayers: true,
            loadMedia: true,
          ),
        ),
      ],
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return BlocConsumer(
            cubit: BlocProvider.of<SingleGameBloc>(context),
            listener: (BuildContext context, SingleGameState state) {
              if (state is SingleGameDeleted) {
                Navigator.pop(context);
              }
            },
            builder: (BuildContext context, SingleGameState state) {
              return _GameDetailsScaffold(state, orientation);
            },
          );
        },
      ),
    );
  }
}

class _GameDetailsScaffold extends StatefulWidget {
  final SingleGameState state;
  final Orientation orientation;

  _GameDetailsScaffold(this.state, this.orientation);

  @override
  State<StatefulWidget> createState() {
    return _GameDetailsScaffoldState();
  }
}

enum _OverflowAction { Video }

class _GameDetailsScaffoldState extends State<_GameDetailsScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.state.game == null
            ? Text(Messages.of(context).titleOfApp)
            : Text(
                "vs " + widget.state.game.opponentName,
                style: Theme.of(context).textTheme.headline5.copyWith(
                    color: (LocalStorageData.isDark(context)
                        ? Colors.white
                        : Colors.white)),
              ),
        actions: <Widget>[
          PopupMenuButton<_OverflowAction>(
            onSelected: _selectedPopup,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<_OverflowAction>(
                  value: _OverflowAction.Video,
                  child: Text(Messages.of(context).video),
                ),
              ];
            },
          ),
        ],
      ),
      body: SavingOverlay(
        saving: widget.state is SingleGameSaving,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _getBody(context, widget.state),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).indicatorColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.graph),
            title: Text(Messages.of(context).stats),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text(Messages.of(context).players),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.chartLine),
            title: Text(Messages.of(context).timeline),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.scatterPlot),
            title: Text(Messages.of(context).shots),
          ),
        ],
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: (widget.state is SingleGameUninitialized ||
                  widget.state is SingleGameDeleted) ||
              _currentIndex == 2 ||
              _currentIndex == 3 ||
              widget.state?.game?.currentPeriod == GamePeriod.Finished
          ? null
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: _currentIndex == 1
                  ? FloatingActionButton.extended(
                      onPressed: () => _addPlayer(context),
                      icon: const Icon(Icons.add),
                      label: Text(Messages.of(context).addPlayerButton),
                    )
                  : FloatingActionButton.extended(
                      icon: Icon(MdiIcons.graph),
                      label: Text(Messages.of(context).statsButton),
                      onPressed: () => Navigator.pushNamed(
                          context,
                          "/Game/Stats/" +
                              widget.state.game.uid +
                              "/" +
                              widget.state.game.seasonUid +
                              "/" +
                              widget.state.game.teamUid),
                    ),
            ),
    );
  }

  void _selectedPopup(_OverflowAction action) {
    switch (action) {
      case _OverflowAction.Video:
        Navigator.pushNamed(context, 'Game/Video/${widget.state.game.uid}');
        break;
    }
  }

  String _madeSummary(MadeAttempt attempt) {
    return attempt.made > 0
        ? "${attempt.made}/${attempt.attempts}  " +
            ((attempt.made / attempt.attempts) * 100.0).toStringAsFixed(0) +
            "%"
        : "0/0 (0%)";
  }

  Widget _getBody(BuildContext context, SingleGameState state) {
    if (state is SingleGameDeleted) {
      return DeletedWidget();
    }
    if (state is SingleGameUninitialized) {
      return LoadingWidget();
    }
    if (_currentIndex == 0) {
      TextStyle headerStyle = Theme.of(context).textTheme.subtitle1.copyWith(
          fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.25,
          color: LocalStorageData.darken(Theme.of(context).indicatorColor, 20),
          fontWeight: FontWeight.bold);
      TextStyle dataStyle = Theme.of(context).textTheme.subtitle1.copyWith(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.35,
          );
      TextStyle opponentDataStyle =
          Theme.of(context).textTheme.subtitle1.copyWith(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
              );
      TextStyle pointsStyle = Theme.of(context).textTheme.subtitle1.copyWith(
          fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 4.0);

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) =>
            SingleChildScrollView(
          child: Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Hero(
                    tag: "game" + state.game.uid,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(state.game.summary.pointsFor.toString(),
                            style: pointsStyle),
                        SizedBox(width: 30.0, child: Icon(Icons.add_circle)),
                        Text(state.game.summary.pointsAgainst.toString(),
                            style: pointsStyle),
                        state.media.length > 0
                            ? IconButton(
                                color: Theme.of(context).accentColor,
                                icon: Icon(Icons.videocam, size: 40.0),
                                onPressed: () => Navigator.pushNamed(context,
                                    'Game/Video/${widget.state.game.uid}'),
                              )
                            : SizedBox(width: 0.0),
                      ],
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/images/basketball.png"),
                              )),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Column(
                        children: [
                          Text(
                              DateFormat("H:m MMM, d")
                                      .format(state.game.eventTime.toLocal()) +
                                  " at " +
                                  state.game.location,
                              style: Theme.of(context).textTheme.headline5),
                          ((state.game.currentPeriod != GamePeriod.NotStarted &&
                                  state.game.currentPeriod !=
                                      GamePeriod.Finished)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Messages.of(context).getPeriodName(
                                          state.game.currentPeriod),
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                      textScaleFactor: 1.5,
                                    ),
                                    GameDuration(
                                      state: state,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                      textScaleFactor: 1.5,
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Text(
                                  "Game Over",
                                  textScaleFactor: 1.2,
                                ))),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1pt", style: headerStyle),
                      Text("2pt", style: headerStyle),
                      Text("3pt", style: headerStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_madeSummary(state.game.playerSummaery.fullData.one),
                          style: dataStyle),
                      Text(_madeSummary(state.game.playerSummaery.fullData.two),
                          style: dataStyle),
                      Text(
                          _madeSummary(
                              state.game.playerSummaery.fullData.three),
                          style: dataStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          _madeSummary(state.game.opponentSummary.fullData.one),
                          style: opponentDataStyle),
                      Text(
                          _madeSummary(state.game.opponentSummary.fullData.two),
                          style: opponentDataStyle),
                      Text(
                          _madeSummary(
                              state.game.opponentSummary.fullData.three),
                          style: opponentDataStyle),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Foul", style: headerStyle),
                      Text("Steals", style: headerStyle),
                      Text("Turnover", style: headerStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(state.game.playerSummaery.fullData.fouls.toString(),
                          style: dataStyle),
                      Text(state.game.playerSummaery.fullData.steals.toString(),
                          style: dataStyle),
                      Text(
                          state.game.playerSummaery.fullData.turnovers
                              .toString(),
                          style: dataStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(state.game.opponentSummary.fullData.fouls.toString(),
                          style: opponentDataStyle),
                      Text(
                          state.game.opponentSummary.fullData.steals.toString(),
                          style: opponentDataStyle),
                      Text(
                          state.game.opponentSummary.fullData.turnovers
                              .toString(),
                          style: opponentDataStyle),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Off Rb", style: headerStyle),
                      Text("Def Db", style: headerStyle),
                      Text("Blocks", style: headerStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          state.game.playerSummaery.fullData.offensiveRebounds
                              .toString(),
                          style: dataStyle),
                      Text(
                          state.game.playerSummaery.fullData.defensiveRebounds
                              .toString(),
                          style: dataStyle),
                      Text(state.game.playerSummaery.fullData.blocks.toString(),
                          style: dataStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          state.game.opponentSummary.fullData.offensiveRebounds
                              .toString(),
                          style: opponentDataStyle),
                      Text(
                          state.game.opponentSummary.fullData.defensiveRebounds
                              .toString(),
                          style: opponentDataStyle),
                      Text(
                          state.game.opponentSummary.fullData.blocks.toString(),
                          style: opponentDataStyle),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (_currentIndex == 1) {
      if (state.game.players.isEmpty) {
        return Text(Messages.of(context).noPlayersWithStats);
      }
      if (!state.loadedPlayers) {
        return LoadingWidget();
      }
      return PlayerDataTable(game: state, orientation: widget.orientation);
      //return PlayerList(game: state.game, orientation: widget.orientation);
    } else if (_currentIndex == 2) {
      return Column(
        children: [
          Expanded(
            child: GameTimeseries(state: state),
          ),
        ],
      );
    } else {
      return GameShotLocations(
        state: state,
      );
    }
  }

  void _addPlayer(BuildContext context) {
    SingleGameBloc bloc = // ignore: close_sinks
        BlocProvider.of<SingleGameBloc>(context);
    showDialog<Tuple2<String, bool>>(
            context: context,
            builder: (BuildContext context) => AddPlayerGameScreen())
        .then((FutureOr<Tuple2<String, bool>> result) async {
      var r = await result;

      if (result == null || r.item1.isEmpty) {
        // Canceled.
        return;
      }
      bloc.add(SingleGameAddPlayer(playerUid: r.item1, opponent: r.item2));
    });
  }
}
