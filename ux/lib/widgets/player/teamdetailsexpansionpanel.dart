import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/game/gametile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';
import '../loading.dart';

///
/// Shows all the exciting details bases on this player.
///
class TeamDetailsExpansionPanel extends StatefulWidget {
  final BuiltList<Game> games;
  final String playerUid;

  TeamDetailsExpansionPanel({@required this.games, @required this.playerUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamDetailsExpansionPanel();
  }
}

class _TeamDetailsExpansionPanel extends State<TeamDetailsExpansionPanel> {
  Map<String, SingleTeamBloc> teamBlocs = {};
  Map<String, SingleSeasonBloc> seasonBlocs = {};
  Map<String, Set<String>> teamSeason = {};

  void initState() {
    super.initState();
    var games = widget.games.toList();
    games.sort((Game a, Game b) => a.seasonUid.compareTo(b.seasonUid));
    games.forEach((Game g) {
      if (!teamSeason.containsKey(g.teamUid)) {
        teamSeason[g.teamUid] = Set();
        teamBlocs[g.teamUid] = SingleTeamBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          teamUid: g.teamUid,
        );
      }
      teamSeason[g.teamUid].add(g.seasonUid);
      if (!seasonBlocs.containsKey(g.seasonUid)) {
        seasonBlocs[g.seasonUid] = SingleSeasonBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          seasonUid: g.seasonUid,
        );
      }
    });
  }

  @override
  void dispose() {
    for (var bloc in teamBlocs.values) {
      bloc.close();
    }
    for (var bloc in seasonBlocs.values) {
      bloc.close();
    }
    teamBlocs = {};
    seasonBlocs = {};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }

  List<ExpansionPanel> _getExpansionPanelList(
      BuildContext context, SinglePlayerState state) {
    // Sort by team and season.
    return teamSeason.keys.map(
      (String teamUid) => ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return BlocBuilder(
            bloc: teamBlocs[teamUid],
            builder: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamUninitialized) {
                return Text(Messages.of(context).loading);
              }
              if (state is SingleTeamDeleted) {
                return Text(Messages.of(context).loading);
              }
              return Text(state.team.name);
            },
          );
        },
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: BlocConsumer(
            bloc: teamBlocs[teamUid],
            builder: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamUninitialized ||
                  state is SingleTeamDeleted) {
                return LoadingWidget();
              }
              return ExpansionPanelList(
                  children: teamSeason[teamUid].map(
                      (String seasonUid) => _getSeasonPanel(seasonUid, state)));
            },
            listener: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamLoaded && !state.loadedSeasons) {
                teamBlocs[teamUid].add(SingleTeamLoadSeasons());
              }
            },
          ),
        ),
      ),
    );
  }

  ExpansionPanel _getSeasonPanel(String seasonUid, SingleTeamBlocState state) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return BlocBuilder(
            bloc: seasonBlocs[seasonUid],
            builder: (BuildContext context, SingleSeasonBlocState state) {
              if (state is SingleSeasonUninitialized) {
                return ListTile(
                  title: Text(Messages.of(context).loading),
                );
              }
              if (state is SingleSeasonDeleted) {
                return ListTile(
                  title: Text(Messages.of(context).unknown),
                );
              }
              var playerData =
                  state.season.playerUids[widget.playerUid].fullData;
              return ListTile(
                title: Text(state.season.name),
                subtitle: Column(
                  children: <Widget>[
                    Text(
                        "Pts ${playerData.points} 1: ${playerData.one.made} of ${playerData.one.attempts} 2: ${playerData.two.made} of ${playerData.two.attempts} 3: ${playerData.three.made} of ${playerData.three.attempts}"),
                    Text(
                        "Stls ${playerData.steals} Blks ${playerData.blocks} Fls ${playerData.fouls}"),
                    Text(
                        "Off rb ${playerData.offensiveRebounds} Def rb ${playerData.defensiveRebounds}"),
                  ],
                ),
              );
            });
      },
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: BlocBuilder(
          bloc: seasonBlocs[seasonUid],
          builder: (BuildContext context, SingleSeasonBlocState state) {
            if (state is SingleSeasonUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (state is SingleSeasonDeleted) {
              return Text(Messages.of(context).unknown);
            }
            // Show the games.
            return Column(
                children: widget.games
                    .where((Game g) => g.seasonUid == seasonUid)
                    .map((Game g) => GameTile(
                          game: g,
                        ))
                    .toList());
          },
        ),
      ),
    );
  }
}
