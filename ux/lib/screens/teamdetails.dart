import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/deleted.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/gametile.dart';
import '../widgets/playertile.dart';
import '../widgets/savingoverlay.dart';
import 'addplayer.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String teamUid;

  TeamDetailsScreen({@required this.teamUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamDetailsScreenState();
  }
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  int _currentIndex = 0;

  Widget _innerData(SingleTeamBlocState state) {
    if (_currentIndex == 0) {
      Widget inner;
      if (!state.loadedGames) {
        inner = Center(
          child: Text(
            Messages.of(context).loading,
            textScaleFactor: 2.0,
          ),
        );
      } else if (state.games.isEmpty) {
        inner = Center(
          child: Text(
            Messages.of(context).noGames,
            textScaleFactor: 2.0,
          ),
        );
      } else {
        inner = ListView(
          children: state.games
              .map(
                (Game g) => Padding(
                    padding: EdgeInsets.all(5.0),
                    child: GameTile(
                      game: g,
                      onTap: () =>
                          Navigator.pushNamed(context, "/Game/" + g.uid),
                    )),
              )
              .toList(),
        );
      }
      return Column(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text(
                state.team.name,
                textScaleFactor: 1.5,
              ),
              subtitle: Text(
                "${state.team.playerUids.length} players",
                textScaleFactor: 1.5,
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () =>
                    Navigator.pushNamed(context, "/EditTeam/" + widget.teamUid),
              ),
            ),
          ),
          Expanded(
            child: inner,
          ),
        ],
      );
    } else {
      if (state.team.playerUids.isEmpty) {
        return Center(
          child: Text(Messages.of(context).noPlayers),
        );
      }
      return ListView(
        children: state.team.playerUids.keys
            .map((String str) => PlayerTile(
                  playerUid: str,
                  onTap: () => Navigator.pushNamed(context, "/Player/" + str),
                ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        var bloc = SingleTeamBloc(
            db: BlocProvider.of<TeamsBloc>(context).db,
            teamUid: widget.teamUid);
        bloc.add(SingleTeamLoadGames());
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
              if (!state.loadedGames && !(state is SingleTeamUninitialized)) {
                BlocProvider.of<SingleTeamBloc>(context)
                    .add(SingleTeamLoadGames());
              }
              if (state is SingleTeamDeleted) {
                print("Pop deleted");
                Navigator.pop(context);
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
                  child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: _innerData(state)));
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
              return FloatingActionButton(
                onPressed: _currentIndex == 0
                    ? () => _addGame(context, state.team.uid, state)
                    : () => _addPlayer(context),
                tooltip: _currentIndex == 0
                    ? Messages.of(context).addGameTooltip
                    : Messages.of(context).addPlayerTooltip,
                child: Icon(Icons.add),
              );
            },
          ),
        );
      }),
    );
  }

  void _addGame(
      BuildContext context, String teamUid, SingleTeamBlocState state) {
    if (state.team.playerUids.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(Messages.of(context).noPlayers),
          content: Text(
            Messages.of(context).noPlayersForTeamDialog,
            softWrap: true,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                print("Ok button");
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, "/AddGame/" + teamUid);
    }
  }

  void _addPlayer(BuildContext context) {
    SingleTeamBloc bloc = // ignore: close_sinks
        BlocProvider.of<SingleTeamBloc>(context);
    showDialog<String>(
            context: context,
            builder: (BuildContext context) => AddPlayerScreen())
        .then((FutureOr<String> playerUid) {
      if (playerUid == null || playerUid == "") {
        // Canceled.
        return;
      }
      bloc.add(SingleTeamAddPlayer(playerUid: playerUid));
    });
  }
}
