import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      child: Text("Frog"),
    );
  }
}
