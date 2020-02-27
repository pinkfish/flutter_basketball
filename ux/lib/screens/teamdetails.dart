import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/gametile.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/playertile.dart';
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
      if (!state.loadedGames) {
        return Center(
          child: Text(Messages.of(context).loading),
        );
      }
      if (state.games.isEmpty) {
        return Center(
          child: Text(Messages.of(context).noGames),
        );
      }
      return ListView(
        children: state.games
            .map((Game g) => GameTile(
                  gameUid: g.uid,
                ))
            .toList(),
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
                ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SingleTeamBloc(
          teamBloc: BlocProvider.of<TeamsBloc>(context),
          teamUid: widget.teamUid),
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(Messages.of(context).title),
          ),
          body: BlocListener(
            bloc: BlocProvider.of<SingleTeamBloc>(context),
            listener: (BuildContext context, SingleTeamBlocState state) {
              if (!state.loadedGames) {
                BlocProvider.of<SingleTeamBloc>(context)
                    .add(SingleTeamLoadGames());
              }
              if (state is SingleTeamDeleted) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
                bloc: BlocProvider.of<SingleTeamBloc>(context),
                builder: (BuildContext context, SingleTeamBlocState state) {
                  print(state);
                  if (state is SingleTeamDeleted) {
                    return Text(Messages.of(context).loading);
                  }
                  return SavingOverlay(
                      saving: state is SingleTeamSaving,
                      child: _innerData(state));
                }),
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
                      ? () => _addGame(context, state.team.uid)
                      : _addPlayer,
                  tooltip: _currentIndex == 0
                      ? Messages.of(context).addGameTooltip
                      : Messages.of(context).addPlayerTooltip,
                  child: Icon(Icons.add),
                );
              }),
        );
      }),
    );
  }

  void _addGame(BuildContext context, String teamUid) {
    Navigator.pushNamed(context, "/AddGame/" + teamUid);
  }

  void _addPlayer() {
    SingleTeamBloc bloc = BlocProvider.of<SingleTeamBloc>(context); // ignore: close_sinks
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
