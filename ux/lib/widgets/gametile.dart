import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final Game game;
  final Function onTap;

  GameTile({@required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("vs " + game.opponentName + " at " + game.location),
      subtitle: Text(game.eventTime.toLocal().toString()),
      onTap: this.onTap,
    );
  }
}
