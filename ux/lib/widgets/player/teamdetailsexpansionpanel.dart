import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  Set<String> expandedPanels = Set();
  Set<String> loadedStuff = Set();

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
    if (teamSeason.length == 1) {
      expandedPanels.add(teamSeason.keys.first);
    }
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
    List<String> teams = teamSeason.keys.toList();
    return ExpansionPanelList(
      expansionCallback: (int item, bool expanded) {
        setState(() {
          if (!expanded) {
            expandedPanels.add(teams[item]);
          } else {
            expandedPanels.remove(teams[item]);
          }
        });
      },
      children: _getExpansionPanelList(context, teams),
    );
  }

  List<ExpansionPanel> _getExpansionPanelList(
      BuildContext context, List<String> teams) {
    // Sort by team and season.
    return teams
        .map(
          (String teamUid) => ExpansionPanel(
            isExpanded: expandedPanels.contains(teamUid),
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
                  return ListTile(
                    title: Text(
                      state.team.name,
                      style: Theme.of(context).textTheme.title,
                    ),
                    leading: Icon(MdiIcons.tshirtCrew),
                  );
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
                  List<String> seasons = teamSeason[teamUid].toList();
                  return ExpansionPanelList(
                      expansionCallback: (int item, bool expanded) {
                        setState(() {
                          if (!expanded) {
                            expandedPanels.add(seasons[item]);
                          } else {
                            expandedPanels.remove(seasons[item]);
                          }
                        });
                      },
                      children: seasons
                          .map((String seasonUid) =>
                              _getSeasonPanel(seasonUid, state))
                          .toList());
                },
                listener: (BuildContext context, SingleTeamBlocState state) {
                  if (state is SingleTeamLoaded && !state.loadedSeasons) {
                    teamBlocs[teamUid].add(SingleTeamLoadSeasons());
                  }
                  if (state is SingleTeamLoaded &&
                      !loadedStuff.contains(state.team.uid)) {
                    setState(() {
                      expandedPanels.add(state.team.currentSeasonUid);
                    });
                    loadedStuff.add(state.team.uid);
                  }
                },
              ),
            ),
          ),
        )
        .toList();
  }

  ExpansionPanel _getSeasonPanel(String seasonUid, SingleTeamBlocState state) {
    return ExpansionPanel(
      isExpanded: expandedPanels.contains(seasonUid),
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
            var playerData = state.season.playerUids[widget.playerUid].fullData;
            return ListTile(
              leading: Icon(MdiIcons.calendar),
              title: Text(
                state.season.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .title,
              ),
              subtitle: getSummaryDetails(playerData),
            );
          },
        );
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
                    .map(
                      (Game g) =>
                      ListTile(
                          title: Text(
                            Messages.of(context)
                                .getGameVs(g.opponentName, g.location),
                            textScaleFactor: 1.25,
                          ),
                          subtitle: getSummaryDetails(
                              g.players[widget.playerUid].fullData)),
                )
                    .toList());
          },
        ),
      ),
    );
  }

  Widget getSummaryDetails(PlayerSummaryData playerData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
            "Pts ${playerData.points} 1: ${playerData.one.made} of ${playerData
                .one.attempts} 2: ${playerData.two.made} of ${playerData.two
                .attempts} 3: ${playerData.three.made} of ${playerData.three
                .attempts}"),
        Text(
            "Stls ${playerData.steals} Blks ${playerData
                .blocks} Fls ${playerData.fouls}"),
        Text(
            "Off rb ${playerData.offensiveRebounds} Def rb ${playerData
                .defensiveRebounds}"),
      ],
    );
  }
}
