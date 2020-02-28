import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/gametile.dart';
import 'package:basketballstats/widgets/playertile.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: Text(Messages.of(context).title),
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
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int i) => setState(() {
          _currentIndex = i;
        }),
        items: [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.graph),
            title: Text(Messages.of(context).stats),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text(Messages.of(context).players),
          ),
        ],
      ),
    );
  }

  Widget _getBody(BuildContext context, SingleGameState state) {
    if (state is SingleGameDeleted) {
      return Center(
        child: Text(Messages.of(context).unknown),
      );
    }
    if (_currentIndex == 0) {
      return GameTile(game: state.game);
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
