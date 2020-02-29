import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/playername.dart';
import 'package:basketballstats/widgets/playertile.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import 'addplayer.dart';

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
      child: Builder(
        builder: (BuildContext context) {
          return BlocListener(
            bloc: BlocProvider.of<SingleGameBloc>(context),
            listener: (BuildContext context, SingleGameState state) {
              if (state is SingleGameDeleted) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              bloc: BlocProvider.of<SingleGameBloc>(context),
              builder: (BuildContext context, SingleGameState state) {
                return _GameDetailsScaffold(state);
              },
            ),
          );
        },
      ),
    );
  }
}

class _GameDetailsScaffold extends StatefulWidget {
  final SingleGameState state;

  _GameDetailsScaffold(this.state);

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
            : Text("vs " + widget.state.game.opponent,
                style: Theme.of(context).textTheme.display1),
      ),
      body: SavingOverlay(
        saving: widget.state is SingleGameSaving,
        child: Center(
          child: _getBody(context, widget.state),
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _addPlayer(context),
              child: Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              icon: Icon(MdiIcons.graph),
              label: Text("START"),
              onPressed: () => Navigator.pushNamed(
                  context,
                  "/GameStats/" +
                      widget.state.game.uid +
                      "/" +
                      widget.state.game.teamUid),
            ),
    );
  }

  String _madeSummary(MadeAttempt attempt) {
    return attempt.made > 0
        ? ((attempt.attempts / attempt.made) * 100.0).toString() + "%"
        : "0/0 (0%)";
  }

  Widget _getBody(BuildContext context, SingleGameState state) {
    if (state is SingleGameDeleted || state is SingleGameUninitialized) {
      return Center(
        child: Text(Messages.of(context).unknown),
      );
    }
    if (_currentIndex == 0) {
      TextStyle dataStyle = Theme.of(context).textTheme.subhead.copyWith(
          fontSize: Theme.of(context).textTheme.subhead.fontSize * 1.25);
      TextStyle minDataStyle = Theme.of(context).textTheme.subhead.copyWith(
          fontSize: Theme.of(context).textTheme.subhead.fontSize * 1.25);
      TextStyle pointsStyle = Theme.of(context).textTheme.subhead.copyWith(
          fontSize: Theme.of(context).textTheme.subhead.fontSize * 4.0);
      return Container(
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
              Text(_madeSummary(state.game.allPlayers.one), style: dataStyle),
              Text(_madeSummary(state.game.allPlayers.two), style: dataStyle),
              Text(_madeSummary(state.game.allPlayers.three), style: dataStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_madeSummary(state.game.opponentPlayers.one),
                  style: dataStyle),
              Text(_madeSummary(state.game.opponentPlayers.two),
                  style: dataStyle),
              Text(_madeSummary(state.game.opponentPlayers.three),
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
              Text(state.game.allPlayers.fouls.toString(), style: dataStyle),
              Text(state.game.allPlayers.steals.toString(), style: dataStyle),
              Text(state.game.allPlayers.turnovers.toString(),
                  style: dataStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.game.opponentPlayers.fouls.toString(),
                  style: dataStyle),
              Text(state.game.opponentPlayers.steals.toString(),
                  style: dataStyle),
              Text(state.game.opponentPlayers.turnovers.toString(),
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
              Text(state.game.allPlayers.offensiveRebounds.toString(),
                  style: dataStyle),
              Text(state.game.allPlayers.defensiveRebounds.toString(),
                  style: dataStyle),
              Text(state.game.allPlayers.blocks.toString(), style: dataStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.game.opponentPlayers.offensiveRebounds.toString(),
                  style: dataStyle),
              Text(state.game.opponentPlayers.defensiveRebounds.toString(),
                  style: dataStyle),
              Text(state.game.opponentPlayers.blocks.toString(),
                  style: dataStyle),
            ],
          ),
          Divider(),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double width = constraints.maxWidth / 6;

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
          Expanded(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    children: state.game.playerUids
                        .map((String s, PlayerSummary p) =>
                            _playerSummary(s, p, constraints))
                        .values
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ]),
      );
    } else {
      if (state.game.playerUids.isEmpty) {
        return Text(Messages.of(context).noPlayers);
      }
      return ListView(
        children: state.game.playerUids.keys
            .map((p) => PlayerTile(
                  playerUid: p,
                ))
            .toList(),
      );
    }
  }

  MapEntry<String, Widget> _playerSummary(
      String uid, PlayerSummary s, BoxConstraints constraints) {
    double width = constraints.maxWidth / 6;
    return MapEntry(
        uid,
        Row(
          children: <Widget>[
            SizedBox(
              width: width * 2,
              child: PlayerName(playerUid: uid),
            ),
            SizedBox(
              width: width,
              child: Text(
                  (s.one.made + s.two.made * 2 + s.three.made * 3).toString()),
            ),
            SizedBox(
              width: width,
              child: Text((s.fouls).toString()),
            ),
            SizedBox(
              width: width,
              child: Text((s.turnovers).toString()),
            ),
            SizedBox(
              width: width,
              child: Text((s.steals).toString()),
            ),
          ],
        ));
  }

  void _addPlayer(BuildContext context) {
    SingleGameBloc bloc = // ignore: close_sinks
        BlocProvider.of<SingleGameBloc>(context);
    showDialog<String>(
            context: context,
            builder: (BuildContext context) => AddPlayerScreen())
        .then((FutureOr<String> playerUid) {
      if (playerUid == null || playerUid == "") {
        // Canceled.
        return;
      }
      bloc.add(SingleGameAddPlayer(playerUid: playerUid));
    });
  }
}
