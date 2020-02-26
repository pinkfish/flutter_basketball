import 'dart:math';

import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import 'playertile.dart';

///
/// Shows the point adding items as buttons on the screen.
///
class GamePlayerDialog extends StatelessWidget {
  final Game game;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    List<Widget> ret = List<Widget>();

    int width = 2;
    List<String> players = game.playerUids.keys;
    for (int i = 0; i < players.length; i += width) {
      ret.add(
        Row(
          children: players
              .sublist(i, min(i + width, players.length))
              .map((String playerUid) => PlayerTile(
                  playerUid: playerUid,
                  onTap: () => _selectPlayer(context, playerUid)))
              .toList(),
        ),
      );
    }
    ret.add(
      ButtonBar(
        children: [
          FlatButton(
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () => Navigator.pop(context, null),
          ),
        ],
      ),
    );
    return ret;
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    Navigator.pop(context, playerUid);
  }

  GamePlayerDialog({@required this.game});
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation o) {
        return ListView(
          children: _populateList(context, o),
        );
      },
    );
  }
}
