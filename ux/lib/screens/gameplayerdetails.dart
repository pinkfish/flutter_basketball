import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/deleted.dart';
import 'package:basketballstats/widgets/game/gameeventlist.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';

///
/// Shows details of the player in the context of the specific game.
///
class GamePlayerDetailsScreen extends StatefulWidget {
  final String playerUid;
  final String gameUid;

  GamePlayerDetailsScreen(this.gameUid, this.playerUid);

  @override
  State<StatefulWidget> createState() {
    return _GameDetailsStateScreen();
  }
}

class _GameDetailsStateScreen extends State<GamePlayerDetailsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SingleGameBloc(
          gameUid: widget.gameUid, db: BlocProvider.of<TeamsBloc>(context).db),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              PlayerName(
                playerUid: widget.playerUid,
              ),
              SizedBox(width: 30.0),
              Builder(
                builder: (BuildContext context) => BlocBuilder(
                  bloc: BlocProvider.of<SingleGameBloc>(context),
                  builder: (BuildContext context, SingleGameState state) {
                    if (state.game != null) {
                      return Text("vs ${state.game.opponentName}");
                    }
                    return Text("");
                  },
                ),
              )
            ],
          ),
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Builder(
            builder: (BuildContext context) {
              if (_currentIndex == 0) {
                return _PlayerDetailBody(widget.playerUid);
              }
              if (_currentIndex == 1) {
                return GameEventList(
                  playerUid: widget.playerUid,
                );
              }
              return Text("frog ${_currentIndex}");
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (pos) => setState(() => _currentIndex = pos),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.portrait),
              title: Text(Messages.of(context).stats),
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.graph),
              title: Text(Messages.of(context).eventList),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerDetailBody extends StatefulWidget {
  final String playerUid;

  _PlayerDetailBody(this.playerUid);

  @override
  State<StatefulWidget> createState() {
    return _PlayerDetailsBodyState();
  }
}

class _PlayerDetailsBodyState extends State<_PlayerDetailBody> {
  GamePeriod period = GamePeriod.NotStarted;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<SingleGameBloc>(context),
      listener: (BuildContext context, SingleGameState state) {},
      builder: (BuildContext context, SingleGameState state) {
        if (state is SingleGameUninitialized) {
          return LoadingWidget();
        }
        if (state is SingleGameDeleted) {
          return DeletedWidget();
        }
        PlayerSummaryData summary;
        TextStyle dataStyle = Theme.of(context).textTheme.subhead.copyWith(
            fontSize: Theme.of(context).textTheme.subhead.fontSize * 1.25);
        TextStyle pointsStyle = Theme.of(context).textTheme.subhead.copyWith(
            fontSize: Theme.of(context).textTheme.subhead.fontSize * 1.5);
        if (period == GamePeriod.NotStarted) {
          summary = state.game.players[widget.playerUid].fullData;
        } else {
          summary = state.game.players[widget.playerUid].perPeriod[period];
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton(
              icon: Icon(
                Icons.arrow_downward,
                size: 30.0,
                color: Theme.of(context).accentColor,
              ),
              iconSize: 24,
              elevation: 16,
              value: period,
              onChanged: (GamePeriod p) => setState(() => period = p),
              items: GamePeriod.values
                  .where((p) =>
                      state.game.players[widget.playerUid].perPeriod
                          .containsKey(p) ||
                      p == GamePeriod.NotStarted)
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p == GamePeriod.NotStarted
                            ? Messages.of(context).allPeriods
                            : Messages.of(context).getPeriodName(p),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.button,
                        textScaleFactor: 1.75,
                      ),
                    ),
                  )
                  .toList(),
            ),
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
                Text(_madeSummary(summary.one), style: dataStyle),
                Text(_madeSummary(summary.two), style: dataStyle),
                Text(_madeSummary(summary.three), style: dataStyle),
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
                Text(summary.fouls.toString(), style: dataStyle),
                Text(summary.steals.toString(), style: dataStyle),
                Text(summary.turnovers.toString(), style: dataStyle),
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
                Text(summary.offensiveRebounds.toString(), style: dataStyle),
                Text(summary.defensiveRebounds.toString(), style: dataStyle),
                Text(summary.blocks.toString(), style: dataStyle),
              ],
            ),
          ],
        );
      },
    );
  }

  String _madeSummary(MadeAttempt attempt) {
    return attempt.made > 0
        ? "${attempt.made}/${attempt.attempts}  " +
            ((attempt.attempts / attempt.made) * 100.0).toString() +
            "%"
        : "0/0 (0%)";
  }
}
