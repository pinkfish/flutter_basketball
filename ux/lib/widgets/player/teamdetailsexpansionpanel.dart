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
  List<Game> sortedGames;
  int sortColumnIndex = 1;
  bool sortAscending = false;

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
                style: Theme.of(context).textTheme.title,
              ),
              subtitle: _getSummaryDetails(playerData),
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
              return Text(Messages
                  .of(context)
                  .loading);
            }
            if (state is SingleSeasonDeleted) {
              return Text(Messages
                  .of(context)
                  .unknown);
            }
            // Show the games.
            TextStyle headerStyle = Theme
                .of(context)
                .textTheme
                .subtitle;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 5.0,
                sortAscending: sortAscending,
                sortColumnIndex: sortColumnIndex,
                columns: [
                  DataColumn(
                    label: Container(
                      width: 50,
                      child: Text(
                        "",
                        overflow: TextOverflow.fade,
                        softWrap: true,
                      ),
                    ),
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
                          .points,
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
                          .steals,
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
                          .blocks,
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
                          .turnovers,
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
                rows: sortedGames
                    .where((Game g) => g.seasonUid == seasonUid)
                    .map(_gameDataRow)
                    .toList(),
              ),
            );
          },
        ),
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
            width: 50,
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

  Widget _getSummaryDetails(PlayerSummaryData playerData) {
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
