import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/teamplayergraphs.dart';
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
  final bool showGraphs;

  TeamDetailsExpansionPanel(
      {@required this.games,
      @required this.playerUid,
      @required this.showGraphs});

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
  List<Game> sortedGames;
  int sortColumnIndex = 1;
  bool sortAscending = false;

  String graphSeasonUid;

  void _buildState() {
    sortedGames = widget.games.toList();
    sortedGames.sort((Game a, Game b) {
      var cmp = a.seasonUid.compareTo(b.seasonUid);
      if (cmp == 0) {
        cmp = b.players[widget.playerUid].fullData.points -
            a.players[widget.playerUid].fullData.points;
      }
      return cmp;
    });
    sortedGames.forEach((Game g) {
      if (!teamSeason.containsKey(g.teamUid)) {
        teamSeason[g.teamUid] = Set();
        teamBlocs[g.teamUid] = SingleTeamBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          teamUid: g.teamUid,
        );
      }
      if (graphSeasonUid == null) {
        graphSeasonUid = g.seasonUid;
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
  void initState() {
    super.initState();
    _buildState();
  }

  @override
  void didUpdateWidget(TeamDetailsExpansionPanel oldWidget) {
    _buildState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<String> teams = teamSeason.keys.toList();
    if (widget.showGraphs) {
      return BlocBuilder(
        bloc: seasonBlocs[graphSeasonUid],
        builder: (BuildContext context, SingleSeasonBlocState state) => Padding(
          padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
          child: TeamPlayerGraphs(
            playerUid: widget.playerUid,
            seasonState: state,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: ExpansionPanelList(
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
      ),
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
                      style: Theme.of(context).textTheme.headline6,
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
                  Iterable<String> seasons = teamSeason[teamUid];
                  return MultiBlocListener(
                    listeners: seasons
                        .map((String s) =>
                        BlocListener(
                          bloc: seasonBlocs[s],
                          listener: (BuildContext context,
                              SingleSeasonBlocState state) {
                            if (state is SingleSeasonLoaded &&
                                !state.loadedGames) {
                              seasonBlocs[s].add(SingleSeasonLoadGames());
                            }
                          },
                        ))
                        .toList(),
                    child: _getDataTableByTeam(state.team),
                  );
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

  Widget _getDataTableByTeam(Team team) {
    List<DataRow> rows = [];
    if (team.currentSeasonUid != null &&
        seasonBlocs.containsKey(team.currentSeasonUid)) {
      Season s = seasonBlocs[team.currentSeasonUid].state.season;

      rows.add(_seasonDataRow(s));
      rows.addAll(sortedGames
          .where((Game g) => g.seasonUid == team.currentSeasonUid)
          .map(_gameDataRow));
    }

    for (String seasonUid in teamSeason[team.uid]) {
      if (seasonUid == team.currentSeasonUid) continue;
      Season s = seasonBlocs[seasonUid].state.season;
      rows.add(_seasonDataRow(s));
      rows.addAll(sortedGames
          .where((Game g) => g.seasonUid == seasonUid)
          .map(_gameDataRow));
    }

    // Show the games.
    TextStyle headerStyle = Theme
        .of(context)
        .textTheme
        .subtitle1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 5.0,
        sortAscending: sortAscending,
        sortColumnIndex: sortColumnIndex,
        columns: [
          DataColumn(
            label: Container(
              width: 60,
              child: Text(
                "",
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.opponentName.compareTo(b.opponentName);
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.points -
                      b.players[widget.playerUid].fullData.points;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
            label: Text(
              Messages
                  .of(context)
                  .pointsTitle,
              style: headerStyle,
            ),
          ),
          DataColumn(
            label: Text(
              "1",
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = _getPercentForSorting(
                      a.players[widget.playerUid].fullData.one) -
                      _getPercentForSorting(
                          b.players[widget.playerUid].fullData.one);
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              "2",
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = _getPercentForSorting(
                      a.players[widget.playerUid].fullData.two) -
                      _getPercentForSorting(
                          b.players[widget.playerUid].fullData.two);
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              "3",
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = _getPercentForSorting(
                      a.players[widget.playerUid].fullData.three) -
                      _getPercentForSorting(
                          b.players[widget.playerUid].fullData.three);
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              Messages
                  .of(context)
                  .offensiveReboundTitle,
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.offensiveRebounds -
                      b.players[widget.playerUid].fullData.offensiveRebounds;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              Messages
                  .of(context)
                  .defensiveReboundTitle,
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.defensiveRebounds -
                      b.players[widget.playerUid].fullData.defensiveRebounds;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              Messages
                  .of(context)
                  .stealsTitle,
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.steals -
                      b.players[widget.playerUid].fullData.steals;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              Messages
                  .of(context)
                  .blocksTitle,
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.blocks -
                      b.players[widget.playerUid].fullData.blocks;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              Messages
                  .of(context)
                  .turnoversTitle,
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.turnovers -
                      b.players[widget.playerUid].fullData.turnovers;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
          DataColumn(
            label: Text(
              Messages
                  .of(context)
                  .fouls,
              style: headerStyle,
            ),
            onSort: (int index, bool ascending) {
              setState(() {
                sortAscending = ascending;
                sortColumnIndex = index;
              });
              sortedGames.sort((Game a, Game b) {
                var cmp = a.seasonUid.compareTo(b.seasonUid);
                if (cmp == 0) {
                  cmp = a.players[widget.playerUid].fullData.fouls -
                      b.players[widget.playerUid].fullData.fouls;
                  cmp *= (sortAscending ? -1 : 1);
                }
                return cmp;
              });
            },
          ),
        ],
        rows: rows,
      ),
    );
  }

  int _getPercentForSorting(MadeAttempt att) {
    if (att == null || att.attempts == 0) {
      return -1;
    }
    return ((att.made ~/ att.attempts) * 100);
  }

  String _getMadeMissed(MadeAttempt att) {
    if (att == null || att.attempts == 0) {
      return "n/a";
    }
    return ((att.made / att.attempts) * 100).toStringAsFixed(0) + "%";
  }

  DataRow _gameDataRow(Game g) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            width: 60,
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              g.opponentName,
              overflow: TextOverflow.fade,
              softWrap: true,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 10,
            child: Text(g.players[widget.playerUid].fullData.points.toString()),
          ),
        ),
        DataCell(
          Text(_getMadeMissed(g.players[widget.playerUid].fullData.one)),
        ),
        DataCell(
          Text(_getMadeMissed(g.players[widget.playerUid].fullData.two)),
        ),
        DataCell(
          Text(_getMadeMissed(g.players[widget.playerUid].fullData.three)),
        ),
        DataCell(
          Text(g.players[widget.playerUid].fullData.offensiveRebounds
              .toString()),
        ),
        DataCell(
          Text(g.players[widget.playerUid].fullData.defensiveRebounds
              .toString()),
        ),
        DataCell(
          Text(g.players[widget.playerUid].fullData.steals.toString()),
        ),
        DataCell(
          Text(g.players[widget.playerUid].fullData.blocks.toString()),
        ),
        DataCell(
          Text(g.players[widget.playerUid].fullData.turnovers.toString()),
        ),
        DataCell(
          Text(g.players[widget.playerUid].fullData.fouls.toString()),
        ),
      ],
    );
  }

  DataRow _seasonDataRow(Season s) {
    TextStyle style = Theme
        .of(context)
        .textTheme
        .bodyText2
        .copyWith(color: Theme
        .of(context)
        .accentColor);
    return DataRow(
      cells: [
        DataCell(
          Container(
            width: 60,
            child: Text(
              s.name,
              overflow: TextOverflow.fade,
              softWrap: true,
              style: style,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 10,
            child: Text(
              s.playerUids[widget.playerUid].summary.points.toString(),
              style: style,
            ),
          ),
        ),
        DataCell(
          Text(
            _getMadeMissed(s.playerUids[widget.playerUid].summary.one),
            style: style,
          ),
        ),
        DataCell(
          Text(
            _getMadeMissed(s.playerUids[widget.playerUid].summary.two),
            style: style,
          ),
        ),
        DataCell(
          Text(
            _getMadeMissed(s.playerUids[widget.playerUid].summary.three),
            style: style,
          ),
        ),
        DataCell(
          Text(
            s.playerUids[widget.playerUid].summary.offensiveRebounds.toString(),
            style: style,
          ),
        ),
        DataCell(
          Text(
            s.playerUids[widget.playerUid].summary.defensiveRebounds.toString(),
            style: style,
          ),
        ),
        DataCell(
          Text(
            s.playerUids[widget.playerUid].summary.steals.toString(),
            style: style,
          ),
        ),
        DataCell(
          Text(
            s.playerUids[widget.playerUid].summary.blocks.toString(),
            style: style,
          ),
        ),
        DataCell(
          Text(
            s.playerUids[widget.playerUid].summary.turnovers.toString(),
            style: style,
          ),
        ),
        DataCell(
          Text(
            s.playerUids[widget.playerUid].summary.fouls.toString(),
            style: style,
          ),
        ),
      ],
    );
  }
}
