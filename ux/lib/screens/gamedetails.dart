import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/game/gameshotlocations.dart';
import '../widgets/game/gametimeseries.dart';
import '../widgets/game/playerlist.dart';
import '../widgets/loading.dart';
import '../widgets/player/playername.dart';
import '../widgets/savingoverlay.dart';
import 'addplayergame.dart';

///
/// Shows details of the game.
///
class GameDetailsScreen extends StatelessWidget {
  final String gameUid;

  GameDetailsScreen(this.gameUid);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SingleGameBloc>(
      create: (BuildContext context) => SingleGameBloc(
          gameUid: gameUid, db: BlocProvider.of<TeamsBloc>(context).db),
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return BlocConsumer(
            bloc: BlocProvider.of<SingleGameBloc>(context),
            listener: (BuildContext context, SingleGameState state) {
              if (state is SingleGameDeleted) {
                Navigator.pop(context);
              }
              if (state is SingleGameLoaded && !state.loadedGameEvents) {
                BlocProvider.of<SingleGameBloc>(context)
                    .add(SingleGameLoadEvents());
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

class _GameDetailsScaffoldState extends State<_GameDetailsScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.state.game == null
            ? Text(Messages.of(context).title)
            : Text("vs " + widget.state.game.opponentName,
                style: Theme.of(context).textTheme.display1),
      ),
      body: SavingOverlay(
        saving: widget.state is SingleGameSaving,
        child: Center(
          child: AnimatedSwitcher(
            child: _getBody(context, widget.state),
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.graph),
              title: Text(Messages.of(context).stats)),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text(Messages.of(context).players)),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.chartLine),
              title: Text(Messages.of(context).timeline)),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.scatterPlot),
              title: Text(Messages.of(context).shots)),
        ],
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: (widget.state is SingleGameUninitialized ||
                  widget.state is SingleGameDeleted) ||
              _currentIndex == 2 ||
              _currentIndex == 3
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
                          "/GameStats/" +
                              widget.state.game.uid +
                              "/" +
                              widget.state.game.seasonUid),
                    ),
            ),
    );
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
      TextStyle minDataStyle = Theme.of(context).textTheme.subhead.copyWith(
          fontSize: Theme.of(context).textTheme.subhead.fontSize * 1.25);
      TextStyle dataStyle = Theme.of(context).textTheme.subhead.copyWith(
          fontSize: Theme.of(context).textTheme.subhead.fontSize * 1.25);
      TextStyle pointsStyle = Theme.of(context).textTheme.subhead.copyWith(
          fontSize: Theme.of(context).textTheme.subhead.fontSize * 4.0);
      Widget retWidget = Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/basketball.png'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(state.game.summary.pointsFor.toString(), style: pointsStyle),
              SizedBox(width: 30.0, child: Icon(Icons.add_circle)),
              Text(state.game.summary.pointsAgainst.toString(),
                  style: pointsStyle),
            ],
          ),
          Divider(),
          Text(
              DateFormat("H:m MMM, d").format(state.game.eventTime.toLocal()) +
                  " at " +
                  state.game.location,
              style: Theme.of(context).textTheme.headline),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1pt",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
              Text("2pt",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
              Text("3pt",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_madeSummary(state.game.playerSummaery.fullData.one),
                  style: dataStyle),
              Text(_madeSummary(state.game.playerSummaery.fullData.two),
                  style: dataStyle),
              Text(_madeSummary(state.game.playerSummaery.fullData.three),
                  style: dataStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_madeSummary(state.game.opponentSummary.fullData.one),
                  style: dataStyle),
              Text(_madeSummary(state.game.opponentSummary.fullData.two),
                  style: dataStyle),
              Text(_madeSummary(state.game.opponentSummary.fullData.three),
                  style: dataStyle),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Foul",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
              Text("Steals",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
              Text("Turnover",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.game.playerSummaery.fullData.fouls.toString(),
                  style: dataStyle),
              Text(state.game.playerSummaery.fullData.steals.toString(),
                  style: dataStyle),
              Text(state.game.playerSummaery.fullData.turnovers.toString(),
                  style: dataStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.game.opponentSummary.fullData.fouls.toString(),
                  style: dataStyle),
              Text(state.game.opponentSummary.fullData.steals.toString(),
                  style: dataStyle),
              Text(state.game.opponentSummary.fullData.turnovers.toString(),
                  style: dataStyle),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Off Rb",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
              Text("Def Db",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
              Text("Blocks",
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold)),
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
                  style: dataStyle),
              Text(
                  state.game.opponentSummary.fullData.defensiveRebounds
                      .toString(),
                  style: dataStyle),
              Text(state.game.opponentSummary.fullData.blocks.toString(),
                  style: dataStyle),
            ],
          ),
          Divider(),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double width = constraints.maxWidth / 6;
            if (widget.orientation == Orientation.landscape) {
              return SizedBox(
                height: 0.0,
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: width * 2,
                  child: Text("",
                      style:
                          minDataStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: width,
                  child: Text("Pts",
                      style:
                          minDataStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: width,
                  child: Text("Fouls",
                      style:
                          minDataStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: width,
                  child: Text("T/O",
                      style:
                          minDataStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: width,
                  child: Text("Steals",
                      style:
                          minDataStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }),
          widget.orientation == Orientation.landscape
              ? SizedBox(
                  height: 0.0,
                )
              : Expanded(
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Column(
                          children: state.game.players.keys
                              .map((String s) => _playerSummary(
                                  s,
                                  state.game.players[s],
                                  constraints,
                                  widget.orientation))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
        ]),
      );
      if (widget.orientation == Orientation.portrait) {
        return retWidget;
      }
      return SingleChildScrollView(child: retWidget);
    } else if (_currentIndex == 1) {
      if (state.game.players.isEmpty) {
        return Text(Messages.of(context).noPlayers);
      }
      return PlayerList(game: state.game, orientation: widget.orientation);
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

  Widget _playerSummary(String uid, PlayerGameSummary s,
      BoxConstraints constraints, Orientation orientation) {
    double width = constraints.maxWidth / 6;
    double scale = orientation == Orientation.portrait ? 1.0 : 1.5;
    return Row(
      children: <Widget>[
        SizedBox(
          width: width * 2,
          child: PlayerName(
            playerUid: uid,
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (s.fullData.one.made +
                s.fullData.two.made * 2 +
                s.fullData.three.made * 3)
                .toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (s.fullData.fouls).toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (s.fullData.turnovers).toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (s.fullData.steals).toString(),
            textScaleFactor: scale,
          ),
        ),
      ],
    );
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
