import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/playertile.dart';
import 'package:basketballstats/widgets/seasons/seasondropdown.dart';
import 'package:basketballstats/widgets/team/teamstats.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';
import '../widgets/seasons/seasonexpansionpanel.dart';
import 'addplayerseason.dart';

///
/// Shows the details for the team, broken down by seasons.
///
class TeamDetailsScreen extends StatefulWidget {
  final String teamUid;
  final Trace loadTrace;

  TeamDetailsScreen({@required this.teamUid, Trace loadTrace})
      : this.loadTrace =
            loadTrace ?? FirebasePerformance.instance.newTrace("loadTeam");

  @override
  State<StatefulWidget> createState() {
    return _TeamDetailsScreenState();
  }
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  Set<String> _expandedPanels = Set();
  bool _loaded = false;
  bool _allLoaded = false;
  int _currentIndex = 0;
  String _seasonPlayers;

  Widget _innerTeamData(SingleTeamBlocState state) {
    Widget inner;
    if (!state.loadedSeasons) {
      inner = Center(
        child: Text(
          Messages.of(context).loadingText,
          textScaleFactor: 2.0,
        ),
      );
    } else if (state.seasons.isEmpty) {
      if (!_allLoaded) {
        widget.loadTrace.incrementMetric("seasons", 0);
        widget.loadTrace.stop();
        _allLoaded = true;
      }
      inner = Center(
        child: Text(
          Messages.of(context).noSeasons,
          textScaleFactor: 2.0,
        ),
      );
    } else {
      if (!_allLoaded) {
        widget.loadTrace.incrementMetric("seasons", state.seasons.length);
        widget.loadTrace.stop();
      }
      inner = ExpansionPanelList(
        expansionCallback: (int index, bool expanded) {
          setState(() {
            if (!expanded) {
              _expandedPanels.add(state.seasons[index].uid);
            } else {
              _expandedPanels.remove(state.seasons[index].uid);
            }
          });
        },
        children: state.seasons
            .map(
              (Season g) => SeasonExpansionPanel(
                season: g,
                currentSeason: state.team.currentSeasonUid,
                isExpanded: _expandedPanels.contains(g.uid),
                loadGames: _expandedPanels.contains(g.uid),
                initiallyExpanded: _expandedPanels.contains(g.uid),
                onGameTapped: (String gameUid) =>
                    RepositoryProvider.of<Router>(context).navigateTo(
                        context, "/Game/View/" + gameUid,
                        transition: TransitionType.inFromRight),
              ),
            )
            .toList(),
      );
    }
    return Column(
      children: [
        Hero(
          tag: "team" + state.team.uid,
          child: Container(
            height: 200.0,
            color: Colors.lightBlue.shade50,
            child: state.team.photoUid != null
                ? Image.network(state.team.photoUid)
                : Image.asset("assets/images/hands_and_trophy.png"),
          ),
        ),
        inner,
      ],
    );
  }

  Widget _innerPlayerData(SingleTeamBlocState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, right: 10),
          child: SeasonDropDown(
            value: _seasonPlayers,
            onChanged: (String str) => setState(() => _seasonPlayers = str),
          ),
        ),
        SingleChildScrollView(
          child: BlocProvider(
            create: (BuildContext context) => SingleSeasonBloc(
                db: RepositoryProvider.of<BasketballDatabase>(context),
                seasonUid: _seasonPlayers),
            child: Builder(
              builder: (BuildContext context) => BlocBuilder(
                cubit: BlocProvider.of<SingleSeasonBloc>(context),
                builder: (BuildContext context, SingleSeasonBlocState state) {
                  if (state is SingleSeasonUninitialized) {
                    return LoadingWidget();
                  }
                  if (state is SingleSeasonDeleted) {
                    return DeletedWidget();
                  }
                  if (!state.loadedPlayers) {
                    BlocProvider.of<SingleSeasonBloc>(context)
                        .add(SingleSeasonLoadPlayers());
                    return LoadingWidget();
                  }
                  // Create a sorted list of players.
                  List<Player> sorted = state.players.values.toList();
                  sorted.sort((p1, p2) => p1.name.compareTo(p2.name));
                  return Column(
                    children: sorted
                        .map((Player p) => PlayerTile(
                              player: p,
                              editButton: false,
                              summary: state.season.playerUids[p.uid],
                              onTap: (String playerUid) => Navigator.pushNamed(
                                  context, "/Player/View/" + p.uid),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        var bloc = SingleTeamBloc(
            db: RepositoryProvider.of<BasketballDatabase>(context),
            teamUid: widget.teamUid);
        bloc.add(SingleTeamLoadSeasons());
        return bloc;
      },
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: BlocBuilder(
              cubit: BlocProvider.of<SingleTeamBloc>(context),
              builder: (BuildContext context, SingleTeamBlocState state) {
                if (state is SingleTeamUninitialized ||
                    state is SingleTeamDeleted) {
                  return Center(
                    child: Text(Messages.of(context).titleOfApp),
                  );
                }
                return Center(
                  child: Text(state.team.name),
                );
              },
            ),
          ),
          body: BlocConsumer(
            cubit: BlocProvider.of<SingleTeamBloc>(context),
            listener: (BuildContext context, SingleTeamBlocState state) {
              if (!state.loadedSeasons && !(state is SingleTeamUninitialized)) {
                BlocProvider.of<SingleTeamBloc>(context)
                    .add(SingleTeamLoadSeasons());
              }
              if (state is SingleTeamDeleted) {
                print("Pop deleted");
                Navigator.pop(context);
              }
              if (state is SingleTeamLoaded) {
                if (!_loaded) {
                  setState(() {
                    _expandedPanels.add(state.team.currentSeasonUid);
                    _seasonPlayers = state.team.currentSeasonUid;
                  });
                }
                _loaded = true;
              }
            },
            builder: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamDeleted) {
                return DeletedWidget();
              }
              if (state is SingleTeamUninitialized) {
                return LoadingWidget();
              }
              if (_currentIndex != 1) {
                return SavingOverlay(
                  saving: state is SingleTeamSaving,
                  child: AnimatedSwitcher(
                    key: Key("gameswitch" + state.team.uid),
                    duration: Duration(milliseconds: 500),
                    child: SingleChildScrollView(
                      child: _currentIndex == 0
                          ? _innerTeamData(state)
                          : _currentIndex == 1
                              ? _innerStatsData(state)
                              : _innerPlayerData(state),
                    ),
                  ),
                );
              }
              return SavingOverlay(
                saving: state is SingleTeamSaving,
                child: AnimatedSwitcher(
                  key: Key("gameswitch" + state.team.uid),
                  duration: Duration(milliseconds: 500),
                  child: _innerStatsData(state),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int i) => setState(() {
              _currentIndex = i;
            }),
            items: [
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.tshirtCrew),
                title: Text(Messages.of(context).seasons),
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.chartLine),
                title: Text(Messages.of(context).stats),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                title: Text(Messages.of(context).players),
              ),
            ],
          ),
          floatingActionButton: BlocBuilder(
            cubit: BlocProvider.of<SingleTeamBloc>(context),
            builder: (BuildContext context, SingleTeamBlocState state) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: _currentIndex == 2
                    ? FloatingActionButton.extended(
                        onPressed: () => _addPlayer(
                            context, BlocProvider.of<SingleTeamBloc>(context)),
                        tooltip: Messages.of(context).addPlayerTooltip,
                        icon: Icon(Icons.add),
                        label: Text(Messages.of(context).addPlayerButton),
                      )
                    : _currentIndex == 0
                        ? SpeedDial(
                            animatedIcon: AnimatedIcons.menu_close,
                            children: [
                              SpeedDialChild(
                                child: Icon(Icons.edit),
                                label: Messages.of(context).editTeamTooltip,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: Colors.black),
                                onTap: () => _addSeason(context, state),
                              ),
                              SpeedDialChild(
                                child: Icon(Icons.add),
                                label: Messages.of(context).addSeasonTooltip,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: Colors.black),
                                onTap: () => _addSeason(context, state),
                              ),
                              SpeedDialChild(
                                child: Icon(MdiIcons.basketball),
                                backgroundColor: Colors.orange,
                                label: Messages.of(context).addGameTooltip,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: Colors.black),
                                onTap: () => _addGame(context, state),
                              ),
                            ],
                          )
                        : SizedBox(height: 0),
              );
            },
          ),
        );
      }),
    );
  }

  void _addSeason(BuildContext context, SingleTeamBlocState state) {
    Navigator.pushNamed(context, "/Season/Add/" + state.team.uid);
  }

  void _addGame(BuildContext context, SingleTeamBlocState state) {
    Navigator.pushNamed(context, "/Game/Add/" + state.team.uid);
  }

  Widget _innerStatsData(SingleTeamBlocState state) {
    return TeamStatsWidget(
      teamUid: state.team.uid,
    );
  }

  void _addPlayer(BuildContext context, SingleTeamBloc bloc) {
    showDialog<Tuple2<String, String>>(
        context: context,
        builder: (BuildContext context) => AddPlayerSeasonScreen(
              defaultSeasonUid: _seasonPlayers,
            )).then((FutureOr<Tuple2<String, String>> playerUid) async {
      if (playerUid == null) {
        // Canceled.
        return;
      }
      var v = await playerUid;
      if (v.item1 == null || v.item1.isEmpty) {
        return;
      }
      bloc.add(
          SingleTeamAddSeasonPlayer(seasonUid: v.item2, playerUid: v.item1));
    });
  }
}
