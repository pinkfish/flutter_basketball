import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameDetailsScreen extends StatelessWidget {
  final String gameUid;

  GameDetailsScreen(this.gameUid);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: SingleGameBloc(gameUid: gameUid, db: ),
    )
  }
}
