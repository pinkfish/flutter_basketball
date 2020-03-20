import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/playertile.dart';
import 'package:basketballstats/widgets/seasons/seasondropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';
import '../widgets/seasons/seasonexpansionpanel.dart';
import 'addplayerseason.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String teamUid;

  TeamDetailsScreen({@required this.teamUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamDetailsScreenState();
  }
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  Set<String> _expandedPanels = Set();
  bool _loaded = false;
  int _currentIndex = 0;
  String _seasonPlayers;

  Widget _innerTeamData(SingleTeamBlocState state) {
    Widget inner;
    if (!state.loadedSeasons) {
      inner = Center(
        child: Text(
          Messages.of(context).loading,
          textScaleFactor: 2.0,
        ),
      );
    } else if (state.seasons.isEmpty) {
      inner = Center(
        child: Text(
          Messages.of(context).noSeasons,
          textScaleFactor: 2.0,
        ),
      );
    } else {
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
                    Navigator.pushNamed(context, "/Game/" + gameUid),
              ),
            )
            .toList(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: Icon(MdiIcons.tshirtCrew),
          title: Text(
            state.team.name,
            textScaleFactor: 1.5,
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () =>
                Navigator.pushNamed(context, "/EditTeam/" + widget.teamUid),
          ),
        ),
        SizedBox(height: 5.0),
        Text(
          Messages
              .of(context)
              .seasons,
          style: Theme
              .of(context)
              .textTheme
              .subhead,
          textScaleFactor: 1.5,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 5.0),
        inner,
      ],
    );
  }

  Widget _innerPlayerData(SingleTeamBlocState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SeasonDropDown(
          value: _seasonPlayers,
          onChanged: (String str) => setState(() => _seasonPlayers = str),
        ),
        SingleChildScrollView(
          child: BlocProvider(
            create: (BuildContext context) =>
                SingleSeasonBloc(
                    db: RepositoryProvider.of<BasketballDatabase>(context),
                    seasonUid: _seasonPlayers),
            child: Builder(
              builder: (BuildContext context) =>
                  BlocBuilder(
                    bloc: BlocProvider.of<SingleSeasonBloc>(context),
                    builder: (BuildContext context,
                        SingleSeasonBlocState state) {
                      if (state is SingleSeasonUninitialized) {
                        return LoadingWidget();
                      }
                      if (state is SingleSeasonDeleted) {
                        return DeletedWidget();
                      }
                      return Column(
                        children: state.season.playerUids.keys
                            .map((String str) =>
                            PlayerTile(
                              playerUid: str,
                              editButton: true,
                              summary: state.season.playerUids[str],
                              onTap: (String playerUid) =>
                                  Navigator.pushNamed(
                                      context, "/Player/" + str),
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
              bloc: BlocProvider.of<SingleTeamBloc>(context),
              builder: (BuildContext context, SingleTeamBlocState state) {
                if (state is SingleTeamUninitialized ||
                    state is SingleTeamDeleted) {
                  return Text(Messages.of(context).title);
                }
                return Text(state.team.name);
              },
            ),
          ),
          body: BlocConsumer(
            bloc: BlocProvider.of<SingleTeamBloc>(context),
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
              return SavingOverlay(
                saving: state is SingleTeamSaving,
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: _currentIndex == 0
                        ? _innerTeamData(state)
                        : _innerPlayerData(state),
                  ),
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
                title: Text(Messages.of(context).stats),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                title: Text(Messages.of(context).players),
              ),
            ],
          ),
          floatingActionButton: BlocBuilder(
            bloc: BlocProvider.of<SingleTeamBloc>(context),
            builder: (BuildContext context, SingleTeamBlocState state) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: FloatingActionButton.extended(
                  onPressed: _currentIndex == 0
                      ? () =>
                          _addGame(context, state.team.currentSeasonUid, state)
                      : () => _addPlayer(
                          context, BlocProvider.of<SingleTeamBloc>(context)),
                  tooltip: _currentIndex == 0
                      ? Messages.of(context).addGameTooltip
                      : Messages.of(context).addPlayerTooltip,
                  icon: Icon(Icons.add),
                  label: _currentIndex == 0
                      ? Text(Messages.of(context).addGameButton)
                      : Text(Messages.of(context).addPlayerButton),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _addGame(
      BuildContext context, String seasonUid, SingleTeamBlocState state) {
    Season s = state.seasons
        .firstWhere((Season s) => s.uid == seasonUid, orElse: () => null);
    if (s.playerUids.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: Text(Messages
                  .of(context)
                  .noPlayers),
              content: Text(
                Messages
                    .of(context)
                    .noPlayersForSeasonDialog,
                softWrap: true,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(MaterialLocalizations
                      .of(context)
                      .okButtonLabel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    } else {
      Navigator.pushNamed(context, "/AddGame/" + seasonUid);
    }
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
