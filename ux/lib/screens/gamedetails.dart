import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/gametile.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// Shows details of the game.
///
class GameDetailsScreen extends StatelessWidget {
  final String gameUid;

  GameDetailsScreen(this.gameUid);

  Widget _getBody(BuildContext context, SingleGameState state) {
    if (state is SingleGameDeleted) {
      return Center(
        child: Text(Messages.of(context).unknown),
      );
    }
    return GameTile(gameUid: state.game.uid);
  }

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
                return Scaffold(
                  appBar: AppBar(
                    title: Text(Messages.of(context).title),
                  ),
                  body: SavingOverlay(
                    saving: state is SingleGameSaving,
                    child: Center(
                      child: _getBody(context, state),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
